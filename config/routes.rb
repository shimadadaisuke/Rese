Rails.application.routes.draw do
  resources :reservations, only: [:new, :create]
  get '/calendars', to: 'calendars#index'
  delete '/reservations/:id/destroy', to: 'reservations#destroy', as: :destroy_reservation

end
