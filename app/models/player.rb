class Player < ApplicationRecord
  belongs_to :club
  belongs_to :user, optional: true
  belongs_to :grade_level, optional: true

  enum :gender, { male: 0, female: 1 }, validate: true
  enum :plus_minus, { minus: -1, neutral: 0, plus: 1 }, validate: true

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :gender, presence: true
  validates :user_id, uniqueness: { scope: :club_id, allow_nil: true, message: "already has a player profile in this club" }

  def full_name
    "#{first_name} #{last_name}"
  end
end
