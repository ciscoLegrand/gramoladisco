Rails.application.routes.draw do
  resources :contacts
  scope module: 'frontend' do
    root 'pages#index'
    resources :albums do
      get :verify_password, on: :member
      post :verify_password, on: :member
      collection do
        post :index
      end
    end
  end
  namespace :admin do
    root 'dashboard#index'
    resources :albums do
      patch :publish, on: :member
      post  :search, on: :collection
    end
    resources :images, only: %i[create]
    delete 'images/:album_id/delete-all', to: 'images#delete_all', as: :delete_all
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
