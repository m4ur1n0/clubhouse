Rails.application.routes.draw do
  get "memberships/create"
  get "memberships/destroy"

  # Email/Password Authentication routes
  get  "/signin",  to: "sessions#new",     as: :signin
  post "/signin",  to: "sessions#create"
  get  "/signup",  to: "registrations#new", as: :signup
  post "/signup",  to: "registrations#create"
  delete "/signout", to: "sessions#destroy", as: :signout

  # OAuth routes
  # google helpers
  get "/auth/google_oauth2",          to: "auth#new",      as: :google_login
  get "/auth/google_oauth2/callback", to: "auth#callback", as: :google_callback
  # regular oauth roots
  get "/auth/:provider", to: "auth#new", as: :auth
  get "/auth/:provider/callback", to: "auth#callback"
  get "/auth/failure", to: "auth#failure"
  get "/logout", to: "auth#logout"


  # this get functions as a post
  resources :events do
        member do
            get :rsvp_start
            post :rsvp
            delete :unrsvp
        end
  end

  resources :clubs do
    member do
        post :rsvp_all_events
    end

    resource :membership, only: [ :create, :destroy ]
    resources :chat_messages, only: [ :create, :edit, :update, :destroy ]
    resources :events, only: [ :index, :new, :create, :edit, :update, :destroy ]
  end

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
