class InfoController < ApplicationController

  def stats
    @groups_amount = Group.count
    @categories_amount = Category.count
    @products_amount = Product.where.not(min_price: nil).count
    @products_all = Product.count
  end

end
