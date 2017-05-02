class Skater < ActiveRecord::Base
  has_many :scores
  has_many :category_results
  has_many :segment_results
end
