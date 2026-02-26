class CreateEventPlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :event_players do |t|
      t.references :event, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.boolean :sitting_out, null: false, default: false
      t.boolean :sat_out_last_round, null: false, default: false

      t.timestamps
    end

    add_index :event_players, [ :event_id, :player_id ], unique: true
  end
end
