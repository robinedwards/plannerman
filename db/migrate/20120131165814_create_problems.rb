class CreateProblems < ActiveRecord::Migration
  def change
    create_table :problems do |t|
      t.string :name
      t.references :subdomain

      t.timestamps
    end
    add_index :problems, :subdomain_id
  end
end
