class Subdomain < ActiveRecord::Base
  validates :name,  :presence => true
  belongs_to :domain
  has_many :problems
end
