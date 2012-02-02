class Domain < ActiveRecord::Base
  validates :name,  :presence => true
end
