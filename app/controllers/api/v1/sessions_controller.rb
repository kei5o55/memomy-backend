module Api
  module V1
    class SessionsController < ApplicationController
      skip_before_action :verify_authenticity_token, raise: false

      def create
        email = params.dig(:user, :email) || params[:email]
        password = params.dig(:user, :password) || params[:password]

        user = User.find_by(email: email)

        if user&.valid_password?(password)
          # 1. JWT トークンを手動生成 (devise-jwt の機能)
          token, _payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)

          # 2. レスポンスヘッダーに Authorization をセット
          response.headers["Authorization"] = "Bearer #{token}"

          render json: {
            status: { code: 200, message: "Logged in successfully." },
            data: {
              id: user.id,
              email: user.email,
              name: user.name
            }
          }, status: :ok
        else
          render json: {
            status: { code: 401, message: "Invalid email or password." }
          }, status: :unauthorized
        end
      end

      def destroy
        # ログアウト処理が必要な場合
        if current_user
          sign_out(current_user)
          render json: { status: 200, message: "Logged out successfully." }, status: :ok
        else
          render json: { status: 401, message: "Couldn't find an active session." }, status: :unauthorized
        end
      end
    end
  end
end
