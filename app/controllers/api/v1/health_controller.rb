# app/controllers/api/v1/health_controller.rb
module Api
  module V1
    class HealthController < ApplicationController
      # Basic 認証を適用（環境変数 BASIC_AUTH_USER / BASIC_AUTH_PASSWORD を使用）
      http_basic_authenticate_with name: ENV.fetch("BASIC_AUTH_USER", "admin"),
                                   password: ENV.fetch("BASIC_AUTH_PASSWORD", "password")

      def show
        render json: { status: "ok", authenticated: true }, status: :ok
      end
    end
  end
end
