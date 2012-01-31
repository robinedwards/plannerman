class Domain < ActiveRecord::Base
  validates :name,  :presence => true
  has_many :subdomains
end
