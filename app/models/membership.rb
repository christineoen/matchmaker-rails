class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :club

  enum :role, { member: 0, admin: 1 }, validate: true

  validates :user_id, uniqueness: { scope: :club_id, message: "is already a member of this club" }
  validates :role, presence: true
end
