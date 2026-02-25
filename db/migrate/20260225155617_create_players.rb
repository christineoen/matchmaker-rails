class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.references :club, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.integer :gender, null: false
      t.references :grade_level, null: true, foreign_key: true
      t.integer :plus_minus, null: false, default: 0

      t.timestamps
    end
    add_index :players, [ :club_id, :user_id ], unique: true, where: "user_id IS NOT NULL"
  end
end
