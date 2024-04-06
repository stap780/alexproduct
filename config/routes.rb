Rails.application.routes.draw do

  require 'sidekiq/web'

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :variants do
    collection do
      post '/:id/create_images', action: 'create_images', as: 'create_images'
    end
  end

  resources :products do
    collection do
      post :delete_selected
      get :import
      get :avito
      get :drom
      post '/:id/create_variants', action: 'create_variants', as: 'create_variants'
      # delete '/:id/images/:image_id', action: 'delete_image', as: 'delete_image'
      post '/:id/image_upload', action: 'image_upload', as: 'image_upload'
      # post :image_upload
      post :delete_image
    end
  end

  # resources :orders do
  #   collection do
  #     post :delete_selected
  #     get :download
  #     post :webhook
  #     get :autocomplete_company_title
  #     get :autocomplete_client_name
  #   end
  # end
  # resources :clients
  root to: 'products#index'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }
  resources :users do
    collection do
      delete '/:id/images/:image_id', action: 'delete_image', as: 'delete_image'
    end
  end
  
end
