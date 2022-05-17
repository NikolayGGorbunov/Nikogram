Rails.application.routes.draw do
  devise_for :users do
    get "/users/sign_out" => 'devise/sessions#destroy'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "posts#index"
  get "/feed", to: "posts#feed"

  resources :posts do
    resources :comments
    resources :likes
  end
  resources :subscribes
  resources :users, only: [:show] do
    resources :subscribes, only:[:create, :destroy]
  end
  # Defines the root path route ("/")
  # root "articles#index"
end
