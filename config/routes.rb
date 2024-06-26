Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "posts#index"

  resources :users, only: %i[edit update index]

  resources :posts, only: %i[new create show index]

  get '/:nickname', to: 'users#show', as: 'user_profile'

  resources :follow_relationships, only: %i[create destroy]

  resources :comments, only: %i[create]

  resources :likes, only: %i[create destroy]
end
