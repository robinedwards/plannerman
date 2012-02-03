class Requirement < ActiveRecord::Base
  validates :name,    :presence => true
  has_many  :domain_requirements
  has_many  :domains, :class_name => 'Domain', :through  => :domain_requirements
end
