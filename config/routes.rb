Rails.application.routes.draw do
  # ... 他のルートがここにあると仮定 ...

  get '/calendars', to: 'calendars#index'
end
