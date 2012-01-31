class CreateSubdomains < ActiveRecord::Migration
  def change
    create_table :subdomains do |t|
      t.string :name
      t.references :domain

      t.timestamps
    end
    add_index :subdomains, :domain_id
  end
end
