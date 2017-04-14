class Score < ActiveRecord::Base
  has_many :technicals, dependent: :destroy
  has_many :components, dependent: :destroy

  belongs_to :competition
  belongs_to :skater
end

class Technical < ActiveRecord::Base
  belongs_to :score
end

class Component < ActiveRecord::Base
  belongs_to :score
end

