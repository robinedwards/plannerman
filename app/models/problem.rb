class Problem < ActiveRecord::Base
  belongs_to :domain

  def path
    [self.domain.directory, self.name].join('/')
  end
end
