class Round < ApplicationRecord
  belongs_to :event
  has_many :matches, dependent: :destroy
  has_many :match_players, through: :matches

  validates :number, presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 1 },
    uniqueness: { scope: :event_id }
end
