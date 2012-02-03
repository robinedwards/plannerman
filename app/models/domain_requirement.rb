class DomainRequirement < ActiveRecord::Base
  validates :domain,      :presence => true
  validates :requirement, :presence => true
  belongs_to :domain
  belongs_to :requirement
end
