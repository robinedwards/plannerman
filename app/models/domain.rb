class Domain < ActiveRecord::Base
  validates :name, :presence => true
  has_many  :domain_requirements
  has_many  :requirements, :class_name => 'Requirement', :through => :domain_requirements
end
