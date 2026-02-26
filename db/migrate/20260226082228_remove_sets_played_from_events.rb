class RemoveSetsPlayedFromEvents < ActiveRecord::Migration[8.0]
  def change
    remove_column :events, :sets_played, :integer
  end
end
