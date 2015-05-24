class ProductsController < ApplicationController

  def index
    @products = Product.all.page(params[:page])
  end
  
end
