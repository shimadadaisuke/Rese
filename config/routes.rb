Rails.application.routes.draw do
  resources :reservations, only: [:new, :create, :destroy]
  get '/calendars', to: 'calendars#index'
  delete '/reservations/:id', to: 'reservations#destroy', as: :destroy_reservation
end
