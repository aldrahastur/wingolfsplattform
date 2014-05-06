Rails.application.routes.draw do
  
  root :to => 'root#index'

  devise_for :user_accounts, :controllers => {:sessions => 'sessions'}
  devise_scope :user_account do
    get 'sign_in', to: 'devise/sessions#new', as: :sign_in
    delete 'sign_out', to: 'devise/sessions#destroy', as: :sign_out
  end
  
  get 'search/guess', to: "search#lucky_guess"
  get :search, to: "search#index"

  resources :users do
    get :autocomplete_title, on: :collection
    put :forgot_password, on: :member
  end

  resources :groups do
    get :mine, on: :collection, to: 'groups#index_mine'
  end
  get :my_groups, to: 'groups#index_mine'

  resources :user_accounts
  resources :pages 
  resources :blog_posts
  resources :attachments
  resources :profile_fields  
  resources :workflows
  resources :user_group_memberships
  resources :status_group_memberships
  resources :relationships

  resources :bookmarks
  get :my_bookmarks, controller: "bookmarks", action: "index"
  
  get "/attachments/:id(/:version)/*basename.:extension", controller: 'attachments', action: 'download', as: 'attachment_download'
    
  get ':alias', to: 'users#show'
  
end
