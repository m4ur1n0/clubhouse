Rails.application.routes.draw do
  # OAuth routes
  get '/auth/:provider', to: 'auth#new', as: :auth
  get '/auth/:provider/callback', to: 'auth#callback'
  get '/auth/failure', to: 'auth#failure'
  get '/logout', to: 'auth#logout'
  
  resources :events
  resources :clubs
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "clubs#index"
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  #   root "/clubs"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
