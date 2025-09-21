Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  namespace :v1 do
    resources :drawings, only: [ :create, :index, :show ]

    resources :predictions, only: [ :create, :show ]
  end
end
