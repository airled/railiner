class CategoriesController < ApplicationController

  def index
    @group = Group.find(params[:group_id])
    @categories = @group.categories.all
  end
  
  def index_all
    @categories = Category.all
  end
  
end
