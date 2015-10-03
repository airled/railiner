class Product < ActiveRecord::Base
  has_and_belongs_to_many :categories
  has_many :costs
  has_many :sellers, :through => :costs
  validates :name, presence: true
end
