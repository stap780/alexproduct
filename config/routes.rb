Rails.application.routes.draw do
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
      delete '/:id/images/:image_id', action: 'delete_image', as: 'delete_image'
    end
  end

  resources :orders do
    collection do
      post :delete_selected
      get :download
      post :webhook
      get :autocomplete_company_title
      get :autocomplete_client_name
    end
  end
  resources :clients
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

  authenticated :user, -> user { user.admin? }  do
    mount DelayedJobWeb, at: "/job"
  end

end
