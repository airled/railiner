class ProductsController < ApplicationController

  def index
    @products = Product.all.page(params[:page])
  end

  def find
    request = params[:form][:product]
    # @products = Product.find_by(:name => params[:form][:product])
    @products = Product.where("name like ?", "%#{request}%") 
    # redirect_to @product.url
  end
  
end
