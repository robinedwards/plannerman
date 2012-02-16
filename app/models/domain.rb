class Domain < ActiveRecord::Base
  validates :name, :presence => true
  validates :domain_file, :presence => true
  validates_uniqueness_of :name
  validates_uniqueness_of :domain_file
  has_many  :domain_requirements
  has_many  :requirements, :class_name => 'Requirement', :through => :domain_requirements
end
