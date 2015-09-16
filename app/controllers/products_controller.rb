class ProductsController < ApplicationController

  def index
    @products = Product.all.page(params[:page])
  end

  def find
    @product = Product.find_by(:name => params[:form][:product])
    redirect_to @product.url
  end
  
end
