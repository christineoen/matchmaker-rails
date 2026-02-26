require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  def valid_player
    Player.new(club: clubs(:riverside), name: "Jane Doe", gender: :female)
  end

  test "valid with required attributes" do
    assert valid_player.valid?
  end

  test "invalid without name" do
    player = valid_player.tap { |p| p.name = nil }
    assert_not player.valid?
    assert_includes player.errors[:name], "can't be blank"
  end

  test "invalid without gender" do
    player = valid_player.tap { |p| p.gender = nil }
    assert_not player.valid?
    assert_includes player.errors[:gender], "can't be blank"
  end

  test "user is optional" do
    player = valid_player
    player.user = nil
    assert player.valid?
  end

  test "grade_level is optional" do
    player = valid_player
    player.grade_level = nil
    assert player.valid?
  end

  test "prevents duplicate user within same club" do
    duplicate = Player.new(club: clubs(:riverside), user: users(:alice), name: "Other Name", gender: :female)
    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].any?
  end

  test "same user can have a player in a different club" do
    player = Player.new(club: clubs(:harbour), user: users(:alice), name: "Alice Admin", gender: :female)
    assert player.valid?
  end

  test "name is stored and returned directly" do
    assert_equal "Alice Admin", players(:alice_riverside).name
  end

  test "gender enum: male is 0, female is 1" do
    assert_equal 0, players(:bob_riverside).gender_before_type_cast
    assert_equal 1, players(:alice_riverside).gender_before_type_cast
  end

  test "grade_offset defaults to 0" do
    player = valid_player
    player.save!
    assert_equal 0, player.grade_offset
  end

  test "grade_offset accepts values between -0.4 and 0.4 inclusive" do
    [ -0.4, -0.1, 0, 0.1, 0.4 ].each do |value|
      player = valid_player.tap { |p| p.grade_offset = value }
      assert player.valid?, "Expected grade_offset #{value} to be valid"
    end
  end

  test "grade_offset rejects values outside -0.4..0.4" do
    [ -0.5, -1, 0.5, 1 ].each do |value|
      player = valid_player.tap { |p| p.grade_offset = value }
      assert_not player.valid?, "Expected grade_offset #{value} to be invalid"
      assert player.errors[:grade_offset].any?
    end
  end

  test "grade_offset stores the decimal value" do
    assert_equal 0.1, players(:bob_riverside).grade_offset
    assert_equal 0,   players(:unlinked_player).grade_offset
  end

  test "avoids_hard_courts defaults to false" do
    player = valid_player
    player.save!
    assert_not player.avoids_hard_courts?
  end

  test "avoids_hard_courts can be set to true" do
    player = valid_player.tap { |p| p.avoids_hard_courts = true }
    assert player.valid?
    assert player.avoids_hard_courts?
  end
end
