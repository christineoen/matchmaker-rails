class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.references :club, null: false, foreign_key: true
      t.string :label
      t.datetime :started_at, null: false
      t.integer :gender_format, null: false
      t.integer :sets_played, null: false, default: 0

      t.timestamps
    end
  end
end
