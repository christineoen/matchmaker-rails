require "test_helper"

class MatchGeneratorTest < ActiveSupport::TestCase
  setup do
    @club = clubs(:riverside)
    @event = Event.create!(
      club: @club,
      started_at: Time.current,
      gender_format: :mixed
    )

    grade = grade_levels(:grade1_riverside)

    # Create 4 players: 2M + 2F
    @p1 = Player.create!(club: @club, name: "Male A", gender: :male, grade_level: grade, grade_offset: 0)
    @p2 = Player.create!(club: @club, name: "Male B", gender: :male, grade_level: grade, grade_offset: 0)
    @p3 = Player.create!(club: @club, name: "Female A", gender: :female, grade_level: grade, grade_offset: 0)
    @p4 = Player.create!(club: @club, name: "Female B", gender: :female, grade_level: grade, grade_offset: 0)

    @court = courts(:court1_riverside)

    @event.event_courts.create!(court: @court)
    [ @p1, @p2, @p3, @p4 ].each { |p| @event.event_players.create!(player: p, sitting_out: false) }
  end

  test "creates a round with matches and match_players" do
    round = MatchGenerator.new(@event, round_number: 1).call

    assert_not_nil round
    assert_equal 1, round.number
    assert_equal @event, round.event
    assert_equal 1, round.matches.count
    assert_equal 4, round.match_players.count
  end

  test "assigns match to the correct court" do
    round = MatchGenerator.new(@event, round_number: 1).call
    assert_equal @court, round.matches.first.court
  end

  test "each match has 2 team_a and 2 team_b players" do
    round = MatchGenerator.new(@event, round_number: 1).call
    match = round.matches.first
    assert_equal 2, match.match_players.select(&:team_a?).count
    assert_equal 2, match.match_players.select(&:team_b?).count
  end

  test "excludes sitting_out players" do
    @event.event_players.find_by(player: @p1).update!(sitting_out: true)

    round = MatchGenerator.new(@event, round_number: 1).call
    played_ids = round.match_players.map(&:player_id)
    assert_not_includes played_ids, @p1.id
  end

  test "regenerate replaces existing round" do
    MatchGenerator.new(@event, round_number: 1).call
    assert_equal 1, @event.rounds.count

    MatchGenerator.new(@event, round_number: 1).call
    assert_equal 1, @event.rounds.count
    assert_equal 1, Round.where(event: @event, number: 1).count
  end

  test "subsequent round numbers increment" do
    r1 = MatchGenerator.new(@event, round_number: 1).call
    r2 = MatchGenerator.new(@event, round_number: 2).call
    assert_equal 1, r1.number
    assert_equal 2, r2.number
  end

  test "players who played last round get sit-out priority with 5 players and 1 court" do
    extra = Player.create!(club: @club, name: "Extra Male", gender: :male,
                           grade_level: grade_levels(:grade1_riverside), grade_offset: 0)
    @event.event_players.create!(player: extra, sitting_out: false)

    # Round 1: all 5 available, 1 sits out
    r1 = MatchGenerator.new(@event, round_number: 1).call
    played_r1_ids = r1.match_players.map(&:player_id).to_set
    sat_out_r1_id = ([ @p1, @p2, @p3, @p4, extra ].map(&:id).to_set - played_r1_ids).first

    # Round 2: whoever sat out round 1 should play
    r2 = MatchGenerator.new(@event, round_number: 2).call
    played_r2_ids = r2.match_players.map(&:player_id).to_set
    assert_includes played_r2_ids, sat_out_r1_id
  end

  test "same_sex format groups all players together" do
    @event.update!(gender_format: :same_sex)
    round = MatchGenerator.new(@event, round_number: 1).call
    assert_equal 4, round.match_players.count
  end

  test "avoids_hard_courts players get non-hard courts when available" do
    hard_court = Court.create!(club: @club, name: "H", surface: "hard")
    @event.event_courts.create!(court: hard_court)
    @p1.update!(avoids_hard_courts: true)
    @p2.update!(avoids_hard_courts: true)

    # Add 4 more players for the second court
    grade = grade_levels(:grade1_riverside)
    4.times do |i|
      p = Player.create!(club: @club, name: "Extra #{i}", gender: :male, grade_level: grade, grade_offset: 0)
      @event.event_players.create!(player: p, sitting_out: false)
    end

    round = MatchGenerator.new(@event, round_number: 1).call

    # Find which match has p1 or p2
    avoiding_player_ids = [ @p1.id, @p2.id ]
    match_with_avoiders = round.matches.find { |m|
      m.match_players.any? { |mp| avoiding_player_ids.include?(mp.player_id) }
    }
    assert_not_nil match_with_avoiders
    assert_not_equal "hard", match_with_avoiders.court.surface
  end

  test "sets_played returns round count" do
    assert_equal 0, @event.sets_played
    MatchGenerator.new(@event, round_number: 1).call
    @event.reload
    assert_equal 1, @event.sets_played
  end
end
