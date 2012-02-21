class AddDomainDirectoryColumn < ActiveRecord::Migration
  def up
    remove_column :domains, :domain_file
    add_column :domains, :directory, :string
    add_column :domains, :file,      :string
  end

  def down
    raise "Fail"
  end
end
