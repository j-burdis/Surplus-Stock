Rails.application.routes.draw do
  devise_for :users, controllers: { 
    registrations: 'users/registrations' 
  }

  # devise_scope :user do
  #   get 'my_account', to: 'users/registrations#edit', as: :my_account
  # end
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
  root to: "pages#home"
  resources :items, only: [:index, :show]
  
  resources :basket_items, only: [:create, :update, :destroy]
  resource :basket, only: [:show]
  
  resources :wishlist_items, only: [:create, :destroy]
  resource :wishlist, only: [:show]
  
  resources :orders, only: [:new, :create, :index, :show] do
    member do
      get :confirmation
      delete :cancel
      patch :save_address
      patch :save_delivery_date 
    end
    resources :payments, only: [:new, :create] do
      get :success, on: :collection
    end
  end

  get 'api/address_lookup', to: 'addresses#lookup'
end
