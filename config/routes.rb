Rails.application.routes.draw do
  root 'calendars#index'
  resources :reservations, only: [:new, :create] do
    member do
      patch 'copy_reservename_to_name'
    end

    collection do
      get 'user'
    end
  end

  get '/calendars', to: 'calendars#index'
  delete '/reservations/:id/destroy', to: 'reservations#destroy', as: :destroy_reservation

  get '/admin', to: 'admin#index'
  get '/admin/reservations', to: 'admin#reservations'

  # ログイン用のルートを追加する
  post '/login', to: 'sessions#create', as: :login
  get '/admin/get_reservations_by_month', to: 'admin#get_reservations_by_month'

  post '/calendars/user_reservation', to: 'reservations#create_user_reservation', as: :user_reservation_create

  # ユーザフォームルートを追加
  get '/calendars/user_reservation', to: 'reservations#user', as: :user_reservation

  post '/admin/copy_reservations', to: 'admin#copy_reservations', as: :copy_reservations
  root 'calendars#index'

end
