Rails.application.routes.draw do
  resources :artifacts
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
    :registrations => "registrations",
    :confirmations => "confirmations",
    :sessions => "milia/sessions",
    :passwords => "milia/passwords",
  }

  match 'plan/edit' => 'tenants#edit', via: :get, as: :edit_plan
  match 'plan/update' => 'tenants#update', via: [:patch, :patch], as: :update_plan

  root :to => "home#index"
end
