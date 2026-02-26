class CreateRounds < ActiveRecord::Migration[8.0]
  def change
    create_table :rounds do |t|
      t.references :event, null: false, foreign_key: true
      t.integer :number, null: false

      t.timestamps
    end

    add_index :rounds, [ :event_id, :number ], unique: true
  end
end
