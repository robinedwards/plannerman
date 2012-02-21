class Domain < ActiveRecord::Base
  validates :name,      :presence => true
  validates :file,      :presence => true
  validates :directory, :presence => true
  validates_uniqueness_of :name
  # TODO validate combination of directory and file
  validates_uniqueness_of :directory
  has_many  :domain_requirements
  has_many  :requirements, :class_name => 'Requirement', :through => :domain_requirements
end
