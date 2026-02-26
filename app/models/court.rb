class Court < ApplicationRecord
  belongs_to :club

  validates :name, presence: true, uniqueness: { scope: :club_id }
  validates :surface, presence: true
  default_scope { order(:name) }
end
