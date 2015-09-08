class CategoriesController < ApplicationController

  def index
    @group = Group.find_by(:name => params[:group_name])
    @categories = @group.categories.all
  end
  
  def index_all
    @categories = Category.all
  end

  def show
    @category = Category.find_by(:name => params[:category_name])
    @products = @category.products.all.page(params[:page])
  end
  
end
