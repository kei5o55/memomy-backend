module Api
  module V1
    class Users::RegistrationsController < Devise::RegistrationsController
      skip_before_action :verify_authenticity_token, raise: false
      respond_to :json

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: {
            status: { code: 200, message: "Signed up successfully." },
            data: resource
          }, status: :ok
        else
          render json: {
            status: { message: "User could not be created successfully.", errors: resource.errors.full_messages }
          }, status: :unprocessable_entity
        end
      end
      # Deviseのストロングパラメータを直接オーバーライドする
      def sign_up_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end
