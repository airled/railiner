class GroupsController < ApplicationController
  
  def index
    @articles = Article.all
  end
  
end
