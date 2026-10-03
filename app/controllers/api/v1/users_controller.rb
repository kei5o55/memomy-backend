class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!, only: [ :me ]

  def create
    @user = User.new(user_params)

    if @user.save
      render json: {
        user: {
          id: @user.id,
          name: @user.name,
          email: @user.email
        }
      }, status: :created
    else
      render json: {
        errors: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
  # GET api/v1/me
  def me
    render json: {
      message: "認証成功！ログイン中のユーザーです",
      user: {
        id: current_user.id,
        name: current_user.name,
        email: current_user.email
      }
    }
  end

  def test
    render json: {
      message: "テステステストだよー",
      timestamp: Time.current
    }
  end

  private

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation
    )
  end
end
