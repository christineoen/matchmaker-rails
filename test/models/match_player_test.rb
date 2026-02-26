require "test_helper"

class MatchPlayerTest < ActiveSupport::TestCase
  def valid_match_player
    MatchPlayer.new(
      match: matches(:match1_riverside),
      player: players(:unlinked_player),
      team: :team_a
    )
  end

  test "valid with required attributes" do
    assert valid_match_player.valid?
  end

  test "invalid without team" do
    mp = valid_match_player.tap { |m| m.team = nil }
    assert_not mp.valid?
    assert_includes mp.errors[:team], "can't be blank"
  end

  test "team_a is 0" do
    assert_equal 0, match_players(:match_player_alice).team_before_type_cast
  end

  test "team_b is 1" do
    assert_equal 1, match_players(:match_player_bob).team_before_type_cast
  end

  test "player must be unique per match" do
    mp = MatchPlayer.new(
      match: matches(:match1_riverside),
      player: players(:alice_riverside),
      team: :team_b
    )
    assert_not mp.valid?
    assert_includes mp.errors[:player_id], "has already been taken"
  end

  test "belongs to match" do
    assert_equal matches(:match1_riverside), match_players(:match_player_alice).match
  end

  test "belongs to player" do
    assert_equal players(:alice_riverside), match_players(:match_player_alice).player
  end
end
