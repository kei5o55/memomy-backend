Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"
      get "me", to: "users#me"
      get "test", to: "users#test"
      post "sync/import", to: "sync#import"
      # devise_for :users はそのまま残しておき、API 用セッションのみカスタムルートを定義
      post 'login', to: 'sessions#create'
      delete 'logout', to: 'sessions#destroy'

      resources :projects, only: [ :index, :create, :destroy, :update ] do
        resources :commits, only: [ :index, :create ]
      end

      resources :work_sessions, only: [ :index, :create ]
      resources :commits, only: [ :index, :destroy ]


      resources :calendar, only: [ :index, :create ]
      resources :day_schedules, only: [ :index, :create, :destroy ]
      resources :calendar_memos, only: [ :index, :create, :update, :destroy ]

      # /api/v1/login, /api/v1/logout, /api/v1/signup にカスタムパスを変更する場合
      devise_for :users,
        path: "",
        path_names: {
          sign_in: "login",
          sign_out: "logout",
          registration: "signup"
        },
        controllers: {
          sessions: "api/v1/sessions",         # コントローラーのディレクトリ階層に合わせて調整
          registrations: "api/v1/registrations"
        },
        skip: [ :confirmations, :unlocks, :sessions ] # 不要な機能をスキップ
    end
  end
end
