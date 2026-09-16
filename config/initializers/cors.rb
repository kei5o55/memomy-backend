# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # 許可するオリジン（開発環境の Next.js サーバー）
    origins "http://localhost:3000", "http://127.0.0.1:3000"

    # ❌ origins '*' は絶対NG
    origins "https://memomy.net" # ⭕️ 公開時は自分のフロントエンドのドメインのみ許可

    # 本番環境など複数許可したい場合は環境変数で渡す設計がおすすめ
    # origins ENV.fetch("ALLOWED_ORIGINS", "http://localhost:3000").split(",")

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      expose: [ "Authorization" ], # トークン認証等をする場合にレスポンスヘッダーを見せる設定
      credentials: true         # Cookie/セッションを使う場合は true
  end
end
