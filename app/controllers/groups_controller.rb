class GroupsController < ApplicationController
  
  def index
    @groups = Group.order('name_ru ASC')
  end

  def show
    @group = Group.find_by(name: params[:name])
    @categories = @group.categories.order('name_ru ASC')
  end
  
end
