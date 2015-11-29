Rails.application.routes.draw do
  get :autocomplete_product_name, to: 'products#autocomplete_product_name'
  get 'find/(page/:page)', to: 'products#find'
  resources :products, only: [:show], param: :url_name

  root 'welcome#index'
  get 'info', to: 'info#stats'

  resources :groups, only: [:index, :show], param: :name
  resources :categories, only: [:index, :show], param: :category_name

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
