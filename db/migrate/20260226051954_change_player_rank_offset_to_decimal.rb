class ChangePlayerRankOffsetToDecimal < ActiveRecord::Migration[8.0]
  def change
    change_column :players, :rank_offset, :decimal, precision: 3, scale: 1, null: false, default: 0.0
  end
end
