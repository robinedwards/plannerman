class AddUniquesToPlanners < ActiveRecord::Migration
  def change
    add_index :planners, [:name, :version, :parameters], :unique => true
  end
end
