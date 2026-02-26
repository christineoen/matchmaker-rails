require "test_helper"

class EventPlayerTest < ActiveSupport::TestCase
  def valid_event_player
    EventPlayer.new(event: events(:event_riverside), player: players(:unlinked_player))
  end

  test "valid with required attributes" do
    assert valid_event_player.valid?
  end

  test "sitting_out defaults to false" do
    ep = valid_event_player
    ep.save!
    assert_not ep.sitting_out?
  end

  test "prevents duplicate player in same event" do
    duplicate = EventPlayer.new(event: events(:event_riverside), player: players(:alice_riverside))
    assert_not duplicate.valid?
    assert duplicate.errors[:player_id].any?
  end

  test "same player can be in different events" do
    ep = EventPlayer.new(event: events(:event_riverside_unlabelled), player: players(:alice_riverside))
    assert ep.valid?
  end

  test "fixture: bob is sitting out" do
    ep = event_players(:event_player_bob)
    assert ep.sitting_out?
  end

  test "fixture: alice is not sitting out" do
    ep = event_players(:event_player_alice)
    assert_not ep.sitting_out?
  end
end
