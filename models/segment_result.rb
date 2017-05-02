class SegmentResult < ActiveRecord::Base
  belongs_to :competition

  belongs_to :skater
end
