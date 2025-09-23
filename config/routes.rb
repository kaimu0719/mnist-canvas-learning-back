Rails.application.routes.draw do
  root to: "rails/health#show", as: :rails_health_check

  resource :session
  resources :passwords, param: :token
  namespace :v1 do
    resources :drawings, only: [ :create, :index, :show ]

    resources :predictions, only: [ :create, :show ]
  end
end
