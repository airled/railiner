class Seller < ActiveRecord::Base
  has_many :costs
  has_many :products, through: :costs
end
