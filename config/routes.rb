Rails.application.routes.draw do
  namespace :v1 do
    resources :drawings, only: [ :create, :index, :show ]
  end
end
