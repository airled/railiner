Rails.application.routes.draw do
  root 'welcome#index'
  get 'info', to: 'info#stats'
  post 'find', to: 'products#find'
  get 'categories/', to: 'categories#index_all'
  get 'products/(page/:page)', to: 'products#index', as: :products
  resources :categories, only: [:show], param: :category_name
  resources :groups, only: [:index], param: :name do
    resources :categories, only: [:index] do
    end
  end
end
