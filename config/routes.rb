Rails.application.routes.draw do
  resources :tenants do
    resources :projects, except: [ :index ]
  end
  resources :members
  get 'home/index'

  # *MUST* come *BEFORE* devise's definitions (below)
  as :user do
    match '/user/confirmation' => 'confirmations#update', :via => :put, :as => :update_user_confirmation
  end

  devise_for :users, :controllers => {
    :registrations => "milia/registrations",
    :confirmations => "confirmations",
    :sessions => "milia/sessions",
    :passwords => "milia/passwords",
  }


  root :to => "home#index"
end
