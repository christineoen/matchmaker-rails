class RemovePositionFromCourts < ActiveRecord::Migration[8.0]
  def change
    remove_column :courts, :position, :integer
  end
end
