class InfoController < ApplicationController

  def stats
    @groups = Group.count
    @categories = Category.count

    @products_in_stock = Product.where.not(min_price: nil).count
    @products_in_stock_uniq = Product.select(:url_name).distinct.where.not(min_price: nil).count

    @products_all = Product.count
    @products_all_uniq = Product.select(:url_name).distinct.count
  end

end
