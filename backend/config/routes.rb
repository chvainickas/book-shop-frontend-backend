Rails.application.routes.draw do
  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication
      post 'auth/login', to: 'authentication#login'
      post 'auth/signup', to: 'authentication#signup'
      get 'auth/me', to: 'authentication#me'

      # Books
      resources :books

      # Categories
      resources :categories, only: [:index, :show]

      # Cart
      get 'cart', to: 'carts#show'
      post 'cart/items', to: 'carts#add_item'
      patch 'cart/items/:id', to: 'carts#update_item'
      delete 'cart/items/:id', to: 'carts#remove_item'
      delete 'cart', to: 'carts#clear'

      # Orders
      resources :orders, only: [:index, :show, :create]

      # Wishlist
      get 'wishlist', to: 'wishlists#index'
      post 'wishlist/items', to: 'wishlists#add_item'
      delete 'wishlist/items/:id', to: 'wishlists#remove_item'
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Catch all route for React frontend
  get '*path', to: 'application#not_found', constraints: ->(req) { !req.xhr? && req.format.html? }
end
