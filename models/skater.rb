class Skater < ActiveRecord::Base
  has_many :scores
  has_many :category_results
end
