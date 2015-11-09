class InfoController < ApplicationController

  before_filter :authenticate_user!

  def stats
    @groups_amount = Group.count
    @categories_amount = Category.count
    @products_amount = Product.where("min_price !=?", "N/A").count
    @products_all = Product.count
  end

end
