class Competition < ActiveRecord::Base
  has_many :scores, dependent: :destroy
  has_many :category_results, dependent: :destroy
end
