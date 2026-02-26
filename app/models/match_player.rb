class MatchPlayer < ApplicationRecord
  belongs_to :match
  belongs_to :player

  enum :team, { team_a: 0, team_b: 1 }, validate: true

  validates :team, presence: true
  validates :player_id, uniqueness: { scope: :match_id }
end
