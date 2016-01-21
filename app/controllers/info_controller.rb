class InfoController < ApplicationController

  # before_filter :authenticate_user!
  # before_filter do 
  #   redirect_to :new_user_session_path unless current_user && current_user.admin?
  # end

  def stats
  end

  def xhr_stats
    @groups = Group.count
    @categories = Category.count
    @products_in_stock = Product.where.not(min_price: nil).count
    @products_in_stock_uniq = Product.select(:url_name).distinct.where.not(min_price: nil).count
    @products_all = Product.count
    @products_all_uniq = Product.select(:url_name).distinct.count
    @users = User.count
    render template: "info/xhr_stats.html.erb", layout: false
  end

end
