class Competition < ActiveRecord::Base
  has_many :scores, dependent: :destroy
  has_many :category_ranks, dependent: :destroy
end
