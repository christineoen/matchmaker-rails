class CreateEventCourts < ActiveRecord::Migration[8.0]
  def change
    create_table :event_courts do |t|
      t.references :event, null: false, foreign_key: true
      t.references :court, null: false, foreign_key: true

      t.timestamps
    end

    add_index :event_courts, [ :event_id, :court_id ], unique: true
  end
end
