Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'showtimes#index'

  resources :showtimes, only: [:index]
  resources :orders, only: [:new, :create]

  namespace :admin do
    root 'root#index'

    namespace :movies do
      get ':id/orders', to: 'orders#index', as: 'orders'
    end

    namespace :auditoriums do
      get ':id/showtimes', to: 'showtimes#index', as: 'showtimes'
    end

    resources :orders, only: [:index]
    resources :movies, only: [:index, :new, :create]
    resources :auditoriums, only: [:index, :new, :create, :edit, :update]
  end

  get '*path' => redirect('/')
end
