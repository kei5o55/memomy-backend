# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :basic_auth, if: -> { Rails.env.production? && ENV["BASIC_AUTH_USER"].present? }

  protected

  def configure_permitted_parameters
    # 新規登録時に name を許可
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :bio, :bgm_url, :icon ])
    # アカウント更新時に name 等を許可
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :bio, :bgm_url, :icon ])
  end

  private

  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV["BASIC_AUTH_USER"] && password == ENV["BASIC_AUTH_PASSWORD"]
    end
  end
end
