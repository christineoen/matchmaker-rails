class ReplacePlayerFirstLastNameWithName < ActiveRecord::Migration[8.0]
  def up
    add_column :players, :name, :string
    execute "UPDATE players SET name = first_name || ' ' || last_name"
    change_column_null :players, :name, false
    remove_column :players, :first_name
    remove_column :players, :last_name
  end

  def down
    add_column :players, :first_name, :string, null: false, default: ""
    add_column :players, :last_name, :string, null: false, default: ""
    execute "UPDATE players SET first_name = split_part(name, ' ', 1), last_name = trim(substring(name from position(' ' in name)))"
    remove_column :players, :name
  end
end
