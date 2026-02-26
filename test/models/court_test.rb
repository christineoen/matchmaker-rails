require "test_helper"

class CourtTest < ActiveSupport::TestCase
  def valid_court
    Court.new(club: clubs(:riverside), name: "3", surface: "grass")
  end

  test "valid with all required attributes" do
    assert valid_court.valid?
  end

  test "invalid without name" do
    court = valid_court.tap { |c| c.name = nil }
    assert_not court.valid?
    assert_includes court.errors[:name], "can't be blank"
  end

  test "invalid without surface" do
    court = valid_court.tap { |c| c.surface = nil }
    assert_not court.valid?
    assert_includes court.errors[:surface], "can't be blank"
  end

  test "invalid with duplicate name within same club" do
    court = Court.new(club: clubs(:riverside), name: courts(:court1_riverside).name, surface: "hard")
    assert_not court.valid?
    assert court.errors[:name].any?
  end

  test "same name is allowed in different clubs" do
    court = Court.new(club: clubs(:harbour), name: courts(:court2_riverside).name, surface: "grass")
    assert court.valid?
  end

  test "default scope orders by name" do
    courts = clubs(:riverside).courts.to_a
    assert_equal courts.map(&:name), courts.map(&:name).sort
  end
end
