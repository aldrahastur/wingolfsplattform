Wingolfsplattform::Application.routes.draw do 

  # mount Mercury::Engine => '/'

  get "map/show"

  # get "angular_test", controller: "angular_test", action: "index"

  # resources :posts

  match "users/new/:alias" => "users#new"

  match 'profile/:alias' => 'users#show', :as => :profile
  
  # http://railscasts.com/episodes/53-handling-exceptions-revised
  match '(errors)/:status', to: 'errors#show', constraints: {status: /\d{3}/} # via: :all
  
  # See how all your routes lay out with "rake routes"

end

