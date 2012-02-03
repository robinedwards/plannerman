class Requirement < ActiveRecord::Base
  validates :name,    :presence => true
  has_many  :domain_requirements
  has_many  :domains, :through  => :domain_requirements
end
