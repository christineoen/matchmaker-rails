require "test_helper"

class ClubTest < ActiveSupport::TestCase
  def valid_club
    Club.new(name: "New Tennis Club")
  end

  test "valid with a name" do
    assert valid_club.valid?
  end

  test "invalid without name" do
    club = Club.new
    assert_not club.valid?
    assert_includes club.errors[:name], "can't be blank"
  end

  test "auto-generates slug from name" do
    club = valid_club
    club.valid?
    assert_equal "new-tennis-club", club.slug
  end

  test "slug is not overwritten if already set" do
    club = Club.new(name: "My Club", slug: "custom-slug")
    club.valid?
    assert_equal "custom-slug", club.slug
  end

  test "invalid with duplicate slug" do
    club = Club.new(name: "Riverside Tennis Club", slug: clubs(:riverside).slug)
    assert_not club.valid?
    assert_includes club.errors[:slug], "has already been taken"
  end

  test "slug rejects invalid characters" do
    club = Club.new(name: "OK Name", slug: "has spaces")
    assert_not club.valid?
    assert club.errors[:slug].any?
  end

  test "has_many members through memberships" do
    assert_includes clubs(:riverside).users, users(:alice)
    assert_includes clubs(:riverside).users, users(:bob)
  end

  test "has_many players" do
    assert_includes clubs(:riverside).players, players(:alice_riverside)
  end

  test "has_many courts" do
    assert_includes clubs(:riverside).courts, courts(:court1_riverside)
  end

  test "has_many grade_levels" do
    assert_includes clubs(:riverside).grade_levels, grade_levels(:grade1_riverside)
  end
end
