class AddDomainFileColumn < ActiveRecord::Migration
  def up
    add_column :domains, :domain_file, :string
  end

  def down
    remove_column :domains, :domain_file
  end
end
