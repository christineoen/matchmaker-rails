require "test_helper"

class MatchTest < ActiveSupport::TestCase
  test "belongs to round" do
    assert_equal rounds(:round1_riverside), matches(:match1_riverside).round
  end

  test "belongs to court" do
    assert_equal courts(:court1_riverside), matches(:match1_riverside).court
  end

  test "has many match_players" do
    match = matches(:match1_riverside)
    assert_includes match.match_players, match_players(:match_player_alice)
    assert_includes match.match_players, match_players(:match_player_bob)
  end

  test "has many players through match_players" do
    match = matches(:match1_riverside)
    assert_includes match.players, players(:alice_riverside)
    assert_includes match.players, players(:bob_riverside)
  end

  test "destroying match destroys match_players" do
    match = matches(:match1_riverside)
    assert_difference "MatchPlayer.count", -match.match_players.count do
      match.destroy
    end
  end
end
