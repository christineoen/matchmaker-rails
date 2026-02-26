class Player < ApplicationRecord
  belongs_to :club
  belongs_to :user, optional: true
  belongs_to :grade_level, optional: true

  enum :gender, { male: 0, female: 1 }, validate: true
  validates :name, presence: true
  validates :gender, presence: true
  validates :grade_offset, numericality: { greater_than_or_equal_to: -0.4, less_than_or_equal_to: 0.4 }
  validates :user_id, uniqueness: { scope: :club_id, allow_nil: true, message: "already has a player profile in this club" }
end
