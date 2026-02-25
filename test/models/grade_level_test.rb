require "test_helper"

class GradeLevelTest < ActiveSupport::TestCase
  def valid_grade_level
    GradeLevel.new(club: clubs(:riverside), name: "Grade 3", rank: 3)
  end

  test "valid with club, name, and rank" do
    assert valid_grade_level.valid?
  end

  test "invalid without name" do
    gl = valid_grade_level.tap { |g| g.name = nil }
    assert_not gl.valid?
    assert_includes gl.errors[:name], "can't be blank"
  end

  test "invalid without rank" do
    gl = valid_grade_level.tap { |g| g.rank = nil }
    assert_not gl.valid?
    assert_includes gl.errors[:rank], "can't be blank"
  end

  test "invalid with duplicate rank within same club" do
    gl = GradeLevel.new(club: clubs(:riverside), name: "Duplicate Rank", rank: grade_levels(:grade1_riverside).rank)
    assert_not gl.valid?
    assert gl.errors[:rank].any?
  end

  test "same rank is allowed in different clubs" do
    gl = GradeLevel.new(club: clubs(:harbour), name: "Grade 2", rank: grade_levels(:grade2_riverside).rank)
    assert gl.valid?
  end

  test "invalid with duplicate name within same club" do
    gl = GradeLevel.new(club: clubs(:riverside), name: grade_levels(:grade1_riverside).name, rank: 99)
    assert_not gl.valid?
    assert gl.errors[:name].any?
  end

  test "ordered scope returns grade levels by rank ascending" do
    levels = clubs(:riverside).grade_levels.ordered.to_a
    assert levels.first.rank < levels.last.rank
  end
end
