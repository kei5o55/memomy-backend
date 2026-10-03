module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user!, only: [ :me ]

      # GET /api/v1/me
      def me
        render json: {
          message: "認証成功！ログイン中のユーザーです",
          user: {
            id: current_user.id,
            name: current_user.name,
            email: current_user.email
          }
        }, status: :ok
      end
    end
  end
end
