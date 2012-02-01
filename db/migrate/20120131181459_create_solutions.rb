class CreateSolutions < ActiveRecord::Migration
  def change
    create_table :solutions do |t|
      t.references :planner
      t.references :domain
      t.references :subdomain
      t.references :problem
      t.integer :plan_quality
      t.integer :second_plan_quality
      t.integer :steps
      t.string :notes
      t.string :full_solution
      t.string :full_raw_output

      t.timestamps
    end
    add_index :solutions, :planner_id
    add_index :solutions, :domain_id
    add_index :solutions, :subdomain_id
    add_index :solutions, :problem_id
  end
end
