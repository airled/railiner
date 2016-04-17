class CategoriesController < ApplicationController

  def index
    @categories = Category.where.not(products_quantity: nil).order('name_ru ASC')
  end

  def show
    @category = Category.find_by(:name => params[:category_name])
    @products = @category.products.page(params[:page])
  end
  
end
