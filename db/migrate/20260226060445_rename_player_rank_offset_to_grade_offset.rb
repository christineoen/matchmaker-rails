class RenamePlayerRankOffsetToGradeOffset < ActiveRecord::Migration[8.0]
  def change
    rename_column :players, :rank_offset, :grade_offset
  end
end
