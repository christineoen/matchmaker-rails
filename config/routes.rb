Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  # Registration
  get "sign_up" => "registrations#new", as: :sign_up
  post "sign_up" => "registrations#create"

  resources :clubs, only: [ :index, :show, :new, :create ] do
    resources :grade_levels, except: :show do
      collection { post :import }
    end
    resources :courts, except: :show do
      collection { post :import }
    end
    resources :players, except: :show do
      collection { post :import }
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "clubs#index"
end
