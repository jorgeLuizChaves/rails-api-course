Rails.application.routes.draw do

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :articles , only: [:index, :show, :create, :update, :destroy]

  resources :articles do
    resources :comments, only: [:index, :create]
  end

  post 'login', to: 'access_tokens#create'
  delete 'logout', to: 'access_tokens#destroy'

  post 'sign_up', to: 'registrations#create'
end
