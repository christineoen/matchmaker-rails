Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  # Registration
  get "sign_up" => "registrations#new", as: :sign_up
  post "sign_up" => "registrations#create"

  resources :clubs

  get "up" => "rails/health#show", as: :rails_health_check

  root "clubs#index"
end
