class CreateCourts < ActiveRecord::Migration[8.0]
  def change
    create_table :courts do |t|
      t.references :club, null: false, foreign_key: true
      t.string :name, null: false
      t.string :surface, null: false
      t.integer :position, null: false

      t.timestamps
    end
    add_index :courts, [ :club_id, :name ], unique: true
  end
end
