class Event < ApplicationRecord
  belongs_to :club
  has_many :event_courts, dependent: :destroy
  has_many :courts, through: :event_courts
  has_many :event_players, dependent: :destroy
  has_many :players, through: :event_players
  has_many :rounds, dependent: :destroy

  enum :gender_format, { mixed: 0, same_sex: 1 }, validate: true

  validates :gender_format, presence: true
  validates :started_at, presence: true
  validates :label, length: { maximum: 100 }, allow_blank: true

  def sets_played = rounds.count
end
