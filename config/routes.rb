Rails.application.routes.draw do
  get :autocomplete_product_name, to: 'products#autocomplete_product_name'
  get 'find/(page/:page)', to: 'products#find'
  resources :products, only: [:show], param: :url_name #page of a product

  root 'welcome#index'
  get 'info', to: 'info#stats'

  resources :groups, only: [:index], param: :name do #all the groups
    resources :categories, only: [:index] #categories of a group
  end

  get 'categories/', to: 'categories#index_all' #all the categories
  resources :categories, only: [:show], param: :category_name #products of a category

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
