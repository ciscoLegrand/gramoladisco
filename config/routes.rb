require 'sidekiq/web'

Rails.application.routes.draw do

  devise_for :users,
  controllers: {
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  scope module: 'frontend' do
    root 'pages#index'
    get 'privacy', to: 'pages#privacy'
    resources :albums do
      get  :verify_password,      on: :member
      get  :download_image,       on: :member
      post :verify_password,      on: :member
      post :index,                on: :collection
      post :search,               on: :collection
    end
    resources :contacts, only: %i[index new create]
    resources :users, only: %i[show]
  end

  authenticate :user, lambda { |u| u.admin? || u.superadmin? } do
    mount Sidekiq::Web => '/sidekiq'
    namespace :admin do
      root 'dashboard#index'
      resources :albums do
        patch :publish, on: :member
        post  :search,  on: :collection
      end
      resources :contacts do
        patch :open,    on: :member
        post  :search,  on: :collection
      end
      resources :dashboard, only: %i[index] do
        get  :spaces,       on: :collection
        get  :tasks,        on: :collection
        get  :settings,     on: :collection
        post :execute_task, on: :collection, as: :execute_task
      end
      resources :images, only: %i[create]
      resources :users, only: %i[index show update] do
        post :index, on: :collection
      end
      resources :reviews, except: %i[update delete] do
        post :search, on: :collection
      end
      resources :spam_requests, only: %i[index show delete] do
        post :search, on: :collection
      end
      delete 'images/:album_id/delete-all', to: 'images#delete_all', as: :delete_all
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
