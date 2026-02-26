class CreateMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :matches do |t|
      t.references :round, null: false, foreign_key: true
      t.references :court, null: false, foreign_key: true

      t.timestamps
    end
  end
end
