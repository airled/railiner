class CategoriesController < ApplicationController

  def index
    @categories = Category.all
  end

  def show
    @category = Category.find_by(:name => params[:category_name])
    @products = @category.products.all.page(params[:page])
  end
  
end
