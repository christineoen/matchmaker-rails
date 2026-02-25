require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  def valid_player
    Player.new(club: clubs(:riverside), first_name: "Jane", last_name: "Doe", gender: :female)
  end

  test "valid with required attributes" do
    assert valid_player.valid?
  end

  test "invalid without first_name" do
    player = valid_player.tap { |p| p.first_name = nil }
    assert_not player.valid?
    assert_includes player.errors[:first_name], "can't be blank"
  end

  test "invalid without last_name" do
    player = valid_player.tap { |p| p.last_name = nil }
    assert_not player.valid?
    assert_includes player.errors[:last_name], "can't be blank"
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
    duplicate = Player.new(club: clubs(:riverside), user: users(:alice), first_name: "Other", last_name: "Name", gender: :female)
    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].any?
  end

  test "same user can have a player in a different club" do
    player = Player.new(club: clubs(:harbour), user: users(:alice), first_name: "Alice", last_name: "Admin", gender: :female)
    assert player.valid?
  end

  test "full_name returns first and last name" do
    assert_equal "Alice Admin", players(:alice_riverside).full_name
  end

  test "gender enum: male is 0, female is 1" do
    assert_equal 0, players(:bob_riverside).gender_before_type_cast
    assert_equal 1, players(:alice_riverside).gender_before_type_cast
  end

  test "plus_minus defaults to neutral (0)" do
    player = valid_player
    player.save!
    assert_equal 0, player.plus_minus_before_type_cast
  end

  test "plus_minus enum values" do
    assert players(:bob_riverside).plus?
    assert players(:unlinked_player).neutral?
  end
end
