class AddSourceColumn < ActiveRecord::Migration
  def up
    add_column :solutions, :source, :string
  end

  def down
    remove_column :solution, :source
  end
end
