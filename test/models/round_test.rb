require "test_helper"

class RoundTest < ActiveSupport::TestCase
  def valid_round
    Round.new(event: events(:event_riverside), number: 99)
  end

  test "valid with required attributes" do
    assert valid_round.valid?
  end

  test "invalid without number" do
    round = valid_round.tap { |r| r.number = nil }
    assert_not round.valid?
    assert_includes round.errors[:number], "can't be blank"
  end

  test "number must be at least 1" do
    round = valid_round.tap { |r| r.number = 0 }
    assert_not round.valid?
  end

  test "number must be unique per event" do
    round = Round.new(event: events(:event_riverside), number: 1)
    assert_not round.valid?
    assert_includes round.errors[:number], "has already been taken"
  end

  test "same number allowed for different events" do
    round = Round.new(event: events(:event_riverside_unlabelled), number: 1)
    assert round.valid?
  end

  test "belongs to event" do
    assert_equal events(:event_riverside), rounds(:round1_riverside).event
  end

  test "has many matches" do
    assert_includes rounds(:round1_riverside).matches, matches(:match1_riverside)
  end

  test "has many match_players through matches" do
    round = rounds(:round1_riverside)
    assert_includes round.match_players, match_players(:match_player_alice)
  end

  test "destroying round destroys matches" do
    round = rounds(:round1_riverside)
    assert_difference "Match.count", -round.matches.count do
      round.destroy
    end
  end
end
