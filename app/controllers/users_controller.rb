class UsersController < ApplicationController

  before_filter :authenticate_user!

  def profile
    @email = current_user.email
    @products = current_user.cart.products
  end

  def add_product
    current_user.cart.products << Product.find(params[:product_id])
    redirect_to :back
  end
end
