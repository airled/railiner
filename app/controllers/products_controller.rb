class ProductsController < ApplicationController

  def index
    @products = Product.all.page(params[:page])
  end

  def find
    request = params[:form][:product]
    if params[:form][:out] == '0'
      @products = Product.where("name like ?", "%#{request}%").where("min_price !=?", "N/A")
    else
      @products = Product.where("name like ?", "%#{request}%")
    end
  end
  
end
