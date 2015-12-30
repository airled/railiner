class Product < ActiveRecord::Base
  has_and_belongs_to_many :categories
  has_many :costs
  has_many :sellers, :through => :costs
  validates :name, presence: true

  def prices
    case
    when self.max_price == self.min_price
      price_to_s(self.min_price) + ' руб.'
    else
      price_to_s(self.min_price) + ' - ' + price_to_s(self.max_price) + ' руб.'
    end
  end

  private

  def price_to_s(price)
    price.to_s.reverse.scan(/\d{1,3}/).join(' ').reverse.strip
  end
  
end
