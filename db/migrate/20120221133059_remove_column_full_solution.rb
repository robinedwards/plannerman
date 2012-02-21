class RemoveColumnFullSolution < ActiveRecord::Migration
  def up
    remove_column :solutions, :full_solution
  end

  def down
    raise 'Fail'
  end
end
