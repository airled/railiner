class GroupsController < ApplicationController
  
  def index
    @groups = Group.all
  end

  def show
    @group = Group.find_by(:name => params[:name])
    @categories = @group.categories.all
  end
  
end
