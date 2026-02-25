require "test_helper"

class UserTest < ActiveSupport::TestCase
  def valid_user
    User.new(email_address: "new@example.com", password: "password", first_name: "Test", last_name: "User")
  end

  test "valid with all required attributes" do
    assert valid_user.valid?
  end

  test "invalid without first_name" do
    user = valid_user.tap { |u| u.first_name = nil }
    assert_not user.valid?
    assert_includes user.errors[:first_name], "can't be blank"
  end

  test "invalid without last_name" do
    user = valid_user.tap { |u| u.last_name = nil }
    assert_not user.valid?
    assert_includes user.errors[:last_name], "can't be blank"
  end

  test "invalid without email_address" do
    user = valid_user.tap { |u| u.email_address = nil }
    assert_not user.valid?
  end

  test "invalid with duplicate email_address" do
    user = valid_user.tap { |u| u.email_address = users(:alice).email_address }
    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "normalizes email to lowercase and stripped" do
    user = valid_user.tap { |u| u.email_address = "  UPPER@Example.COM  " }
    user.valid?
    assert_equal "upper@example.com", user.email_address
  end

  test "full_name returns first and last name" do
    assert_equal "Alice Admin", users(:alice).full_name
  end

  test "has_many clubs through memberships" do
    assert_includes users(:alice).clubs, clubs(:riverside)
  end

  test "has_many players" do
    assert_includes users(:alice).players, players(:alice_riverside)
  end
end
