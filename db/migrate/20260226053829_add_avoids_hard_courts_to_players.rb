class AddAvoidsHardCourtsToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :avoids_hard_courts, :boolean, null: false, default: false
  end
end
