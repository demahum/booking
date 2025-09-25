Rails.application.routes.draw do
  # Authentication routes
  get "login", to: "auth#login", as: "login"
  post "authenticate", to: "auth#authenticate", as: "authenticate"
  get "logout", to: "auth#logout", as: "logout"
  
  # Application routes
  get "home/index"
  post "home/save_range"
  
  # Locale routes - both form-based and API-based approaches that preserve session state
  post "change_locale", to: "application#change_locale", as: "change_locale"
  post "set_locale", to: "application#set_locale_api", as: "set_locale_api"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "home#index"
end
