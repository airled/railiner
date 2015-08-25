class InfoController < ApplicationController

  def stats
    @groups_amount = Group.count
    @categories_amount = Category.count
    @products_amount = Product.count
  end

end
