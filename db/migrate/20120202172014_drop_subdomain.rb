class DropSubdomain < ActiveRecord::Migration
  def up
    remove_column :solutions, :subdomain
    drop_table :subdomains
  end
end
