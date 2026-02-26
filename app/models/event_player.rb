class EventPlayer < ApplicationRecord
  belongs_to :event
  belongs_to :player

  validates :player_id, uniqueness: { scope: :event_id }

  def sat_out_last_round?
    last_round = event.rounds.order(number: :desc).first
    return false if last_round.nil?
    !last_round.match_players.exists?(player_id: player_id)
  end
end
