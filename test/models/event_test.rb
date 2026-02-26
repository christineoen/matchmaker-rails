require "test_helper"

class EventTest < ActiveSupport::TestCase
  def valid_event
    Event.new(club: clubs(:riverside), started_at: Time.current, gender_format: :mixed)
  end

  test "valid with required attributes" do
    assert valid_event.valid?
  end

  test "invalid without started_at" do
    event = valid_event.tap { |e| e.started_at = nil }
    assert_not event.valid?
    assert_includes event.errors[:started_at], "can't be blank"
  end

  test "invalid without gender_format" do
    event = valid_event.tap { |e| e.gender_format = nil }
    assert_not event.valid?
    assert_includes event.errors[:gender_format], "can't be blank"
  end

  test "label is optional" do
    event = valid_event.tap { |e| e.label = nil }
    assert event.valid?
  end

  test "label max 100 chars" do
    event = valid_event.tap { |e| e.label = "a" * 101 }
    assert_not event.valid?
    assert event.errors[:label].any?
  end

  test "label of exactly 100 chars is valid" do
    event = valid_event.tap { |e| e.label = "a" * 100 }
    assert event.valid?
  end

  test "gender_format enum: mixed=0, same_sex=1" do
    assert_equal 0, events(:event_riverside).gender_format_before_type_cast
    assert_equal 1, events(:event_riverside_unlabelled).gender_format_before_type_cast
  end

  test "sets_played defaults to 0" do
    event = valid_event
    event.save!
    assert_equal 0, event.sets_played
  end

  test "sets_played must be non-negative integer" do
    event = valid_event.tap { |e| e.sets_played = -1 }
    assert_not event.valid?
    assert event.errors[:sets_played].any?
  end

  test "belongs to club" do
    assert_equal clubs(:riverside), events(:event_riverside).club
  end

  test "has courts through event_courts" do
    event = events(:event_riverside)
    assert_includes event.courts, courts(:court1_riverside)
    assert_includes event.courts, courts(:court2_riverside)
  end

  test "has players through event_players" do
    event = events(:event_riverside)
    assert_includes event.players, players(:alice_riverside)
    assert_includes event.players, players(:bob_riverside)
  end

  test "destroying event destroys event_courts" do
    event = events(:event_riverside)
    assert_difference "EventCourt.count", -event.event_courts.count do
      event.destroy
    end
  end

  test "destroying event destroys event_players" do
    event = events(:event_riverside)
    assert_difference "EventPlayer.count", -event.event_players.count do
      event.destroy
    end
  end
end
