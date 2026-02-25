class GradeLevel < ApplicationRecord
  belongs_to :club
  has_many :players, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :club_id }
  validates :rank, presence: true, numericality: { only_integer: true }, uniqueness: { scope: :club_id }

  scope :ordered, -> { order(:rank) }
end
