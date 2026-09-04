Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#show"
  resources :users, only: :show
  delete "/user", to: "users#destroy", as: :withdraw_user

  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  post "/logout", to: "sessions#destroy"

  resources :word_chain_walks, only: %i[index create show destroy] do
    get :map, on: :member
    scope module: :word_chain_walks do
      resource :completion, only: %i[show update]
    end
    resources :word_chain_walk_steps, only: %i[create show] do
      delete "latest", on: :collection, action: :destroy_latest
    end
  end

  get "privacy", to: "home#privacy"
end
