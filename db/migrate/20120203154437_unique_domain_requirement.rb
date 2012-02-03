class UniqueDomainRequirement < ActiveRecord::Migration
  def up
    add_index :domain_requirements, [:domains_id, :requirements_id], :unique => true
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'boom'
  end
end
