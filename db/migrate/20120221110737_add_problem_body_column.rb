class AddProblemBodyColumn < ActiveRecord::Migration
  def up
    add_column    :problems, :description, :string
  end

  def down
    remove_column :problems
  end
end
