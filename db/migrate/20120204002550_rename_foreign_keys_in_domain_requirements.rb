class RenameForeignKeysInDomainRequirements < ActiveRecord::Migration
  rename_column :domain_requirements, :domains_id, :domain_id
  rename_column :domain_requirements, :requirements_id, :requirements_id
end
