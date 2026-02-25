require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  def valid_membership
    Membership.new(user: users(:alice), club: clubs(:harbour), role: :member)
  end

  test "valid with user, club, and role" do
    assert valid_membership.valid?
  end

  test "invalid without role" do
    membership = valid_membership.tap { |m| m.role = nil }
    assert_not membership.valid?
  end

  test "prevents duplicate user+club combination" do
    duplicate = Membership.new(user: users(:alice), club: clubs(:riverside), role: :member)
    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].any?
  end

  test "member role is 0" do
    assert_equal 0, memberships(:bob_riverside).role_before_type_cast
  end

  test "admin role is 1" do
    assert_equal 1, memberships(:alice_riverside).role_before_type_cast
  end

  test "admin? returns true for admin role" do
    assert memberships(:alice_riverside).admin?
  end

  test "member? returns true for member role" do
    assert memberships(:bob_riverside).member?
  end
end
