class InfoController < ApplicationController

  def stats
    @groups = Group.count
    @categories = Category.count

    products_in_stock = Product.where.not(min_price: nil)
    @products_stock = products_in_stock.count
    @products_stock_uniq = products_in_stock.group(:url_name).count.count

    @products_all = Product.count
    @products_all_uniq = Product.group(:url_name).count.count
  end

end
