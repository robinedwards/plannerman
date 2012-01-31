class CreatePlanners < ActiveRecord::Migration
  def change
    create_table :planners do |t|
      t.string :name
      t.string :version
      t.string :parameters

      t.timestamps
    end
  end
end
