class ProblemDomainRelationship < ActiveRecord::Migration
  def up
    remove_column :problems, :subdomain
    add_column :problems, :domain, :reference
  end

  def down
    remove_column :problems, :domain
  end
end
