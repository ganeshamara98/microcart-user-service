Rails.application.routes.draw do
  # Authentication routes
  post '/auth/register', to: 'authentication#register'
  post '/auth/login', to: 'authentication#login'
  post '/auth/logout', to: 'authentication#logout'
  get '/auth/me', to: 'authentication#me'

  # User management routes
  resources :users, only: [:index, :show, :update, :destroy]

  # Health check
  get '/health', to: 'health#check'
end
