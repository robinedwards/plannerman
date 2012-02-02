class AddPlannerNotes < ActiveRecord::Migration
  def up
    add_column :planners, :notes, :string
  end
end
