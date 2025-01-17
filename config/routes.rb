Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  resources :users, only: [:new, :create]
  resources :sessions, only: [:new, :create, :destroy]
  resources :locations, only: [:index, :show, :new, :create, :destroy] do
    member do
      get :forecast
    end
    collection do
      post :geocode_address
    end
  end

  get "get_current_location", to: "locations#get_current_location", as: :get_current_location
  get 'forecast', to: 'locations#forecast', as: :forecast

  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"
  get "/logout", to: "sessions#destroy", as: :logout

  root "locations#index"
end
