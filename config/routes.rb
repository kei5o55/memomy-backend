Rails.application.routes.draw do
  # devise_for :users,
  #  path: "api/v1",
  #  path_names: {
  #    sign_in: "login",
  #    sign_out: "logout",
  #    registration: "signup"
  #  },
  #  controllers: {
  #    sessions: "api/v1/sessions",
  #    registrations: "api/v1/registrations"
  #  }
  namespace :api do
    namespace :v1 do
      get "health", to: "health#index"
      get "me", to: "users#me"
      get "test", to: "users#test"
      post "sync/import", to: "sync#import"

      resources :projects, only: [ :index, :create, :destroy, :update ] do
        resources :commits, only: [ :index, :create ]
      end

      resources :work_sessions, only: [ :index, :create ]
      resources :commits, only: [ :index, :destroy ]


      resources :calendar, only: [ :index, :create ]
      resources :day_schedules, only: [ :index, :create, :destroy ]
      resources :calendar_memos, only: [ :index, :create, :update, :destroy ]
    end
  end
end
