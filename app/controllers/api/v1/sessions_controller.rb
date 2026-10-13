module Api
  module V1
    class SessionsController < ApplicationController
      skip_before_action :verify_authenticity_token, raise: false
      skip_before_action :authenticate_user!, only: [ :create ]

      def create
        email = params.dig(:user, :email) || params[:email]
        password = params.dig(:user, :password) || params[:password]

        user = User.find_by(email: email)

        if user&.valid_password?(password)
          # 1. JWT トークンを手動生成 (devise-jwt の機能)
          # スコープは devise_for の登録名 (:api_v1_user) に合わせる。ずれるとログアウト時の失効処理でユーザーを特定できない
          token, _payload = Warden::JWTAuth::UserEncoder.new.call(user, Devise::Mapping.find_scope!(user), nil)

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
        # jti を更新して、このユーザーに発行済みのトークンをすべて失効させる(JTIMatcher方式のログアウト)
        current_user.update!(jti: SecureRandom.uuid)
        render json: { status: { code: 200, message: "Logged out successfully." } }, status: :ok
      end
    end
  end
end
