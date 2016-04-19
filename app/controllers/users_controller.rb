class UsersController < ApplicationController

  before_filter :authenticate_user!

  def profile
    @email = current_user.email
    @products = current_user.cart.products
  end

  def add_product
    product_id = params[:product_id].to_i
    ids = current_user.cart.products.pluck(:id)
    current_user.cart.products << Product.find(product_id) unless ids.include?(product_id)
    render json: current_user.cart.products.count
  end

  def remove_product
    product_id = params[:product_id].to_i
    current_user.cart.products.delete(Product.find(product_id))
    render json: current_user.cart.products.count
  end
  
end
