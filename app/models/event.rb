class Event < ApplicationRecord
  belongs_to :club
  has_many :event_courts, dependent: :destroy
  has_many :courts, through: :event_courts
  has_many :event_players, dependent: :destroy
  has_many :players, through: :event_players

  enum :gender_format, { mixed: 0, same_sex: 1 }, validate: true

  validates :gender_format, presence: true
  validates :started_at, presence: true
  validates :label, length: { maximum: 100 }, allow_blank: true
  validates :sets_played, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
