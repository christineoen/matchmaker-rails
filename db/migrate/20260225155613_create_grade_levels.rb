class CreateGradeLevels < ActiveRecord::Migration[8.0]
  def change
    create_table :grade_levels do |t|
      t.references :club, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :rank, null: false

      t.timestamps
    end
    add_index :grade_levels, [ :club_id, :rank ], unique: true
    add_index :grade_levels, [ :club_id, :name ], unique: true
  end
end
