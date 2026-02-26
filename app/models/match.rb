class Match < ApplicationRecord
  belongs_to :round
  belongs_to :court
  has_many :match_players, dependent: :destroy
  has_many :players, through: :match_players
end
