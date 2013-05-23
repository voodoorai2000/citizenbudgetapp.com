CitizenBudget::Application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resources :responses, only: [:new, :create, :show]
  match ':locale/channel' => 'pages#channel', as: :channel, via: :get
  match 'oauth2callback' => 'pages#oauth2callback', as: :oauth2callback
  root to: 'responses#new'
end
