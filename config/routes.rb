Rails.application.routes.draw do
  root 'welcome#index'
  get 'info', to: 'info#stats'
  get 'categories/', to: 'categories#index_all'
  get 'products/(page/:page)', to: 'products#index', as: :products
  resources :categories, only: [:show] 
  resources :groups, only: [:index] do
    resources :categories, only: [:index] do
    end
  end
end
