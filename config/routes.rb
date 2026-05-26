require "sidekiq/web"

Rails.application.routes.draw do
  # Sidekiq Web UI — only accessible in development (no auth required locally)
  if Rails.env.development?
    mount Sidekiq::Web => "/sidekiq"
  end

  root "home#index"
  devise_for :users

  resources :projects do
    resources :tasks, only: [ :new, :create ]
    resources :project_members, only: [ :create, :destroy ], path: "members"
  end

  resources :tasks, only: [ :show, :edit, :update, :destroy ] do
    resources :comments, only: [ :create, :destroy ]
    resources :attachments, only: [ :destroy ]
  end

  get "search", to: "search#index", as: :search

  get "locale/:locale", to: "locale#switch", as: :switch_locale

  get "up" => "rails/health#show", as: :rails_health_check
end
