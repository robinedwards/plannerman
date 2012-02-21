class AddColumnTime < ActiveRecord::Migration
  def up
    add_column :solutions, :time, :integer
  end

  def down
    remove_column :solutions, :time
  end
end
