class Court < ApplicationRecord
  belongs_to :club

  validates :name, presence: true, uniqueness: { scope: :club_id }
  validates :surface, presence: true
  validates :position, presence: true, numericality: { only_integer: true }

  default_scope { order(:position) }
end
