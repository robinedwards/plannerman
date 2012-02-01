class DomainUniques < ActiveRecord::Migration
  def change
    add_index :domains,    :name,                   :unique => true
    add_index :subdomains, [:domain_id, :name],     :unique => true
    add_index :problems,   [:subdomain_id, :name],  :unique => true
  end
end
