class RenamePlayerPlusMinusToRankOffset < ActiveRecord::Migration[8.0]
  def change
    rename_column :players, :plus_minus, :rank_offset
  end
end
