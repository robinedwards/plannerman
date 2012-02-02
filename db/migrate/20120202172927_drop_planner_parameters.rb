class DropPlannerParameters < ActiveRecord::Migration
  remove_column :planners, :parameters
end
