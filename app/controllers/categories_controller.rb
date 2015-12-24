class CategoriesController < ApplicationController

  def index
    @categories = Category.all
  end

  def show
    @category = Category.find_by(:name => params[:category_name])
    category_products = @category.products
    @amount = category_products.count
    @products = category_products.page(params[:page])
  end
  
end
