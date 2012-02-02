class Solution < ActiveRecord::Base
  belongs_to :planner
  belongs_to :domain
  belongs_to :problem
end
