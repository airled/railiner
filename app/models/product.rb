class Product < ActiveRecord::Base
  has_and_belongs_to_many :categories
  has_many :costs
  has_many :sellers, :through => :costs
  validates :name, presence: true

  def maxprice
    self.max_price.to_s.reverse.scan(/\d{1,3}/).join(' ').reverse.strip
  end

  def minprice
    self.min_price.to_s.reverse.scan(/\d{1,3}/).join(' ').reverse.strip
  end
  
end
