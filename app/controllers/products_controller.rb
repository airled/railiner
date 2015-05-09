class ProductsController < ApplicationController

  def index
    @group = Group.find(params[:group_id])
    @category = @group.categories.find(params[:category_id])
    @products = @category.products.all
  end
  
  def index_all
    @products = Product.all.page(params[:page])
  end
  
end
