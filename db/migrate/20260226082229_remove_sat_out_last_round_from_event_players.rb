class RemoveSatOutLastRoundFromEventPlayers < ActiveRecord::Migration[8.0]
  def change
    remove_column :event_players, :sat_out_last_round, :boolean
  end
end
