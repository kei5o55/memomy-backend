# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # API モードで Devise を使う際に CSRF トークン検証をスキップ
  protect_from_forgery with: :null_session, if: -> { request.format.json? }
  # Devise の認証ヘルパー（authenticate_user!, current_user 等）を有効化
  include Devise::Controllers::Helpers

  # フロントから届く camelCase のキーを、受け取り時に snake_case へ変換する
  before_action :underscore_params_keys
  # ParamsWrapper は before_action より前に動き、`daySchedule` のような camelCase のルートキーだと
  # 空の `day_schedule` を追加して変換後の値を上書きしてしまうため無効化（フロントは常にルートキー付きで送る）
  wrap_parameters false

  # Devise で name など追加パラメータを許可する設定
  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :basic_auth, if: -> { Rails.env.production? && ENV["BASIC_AUTH_USER"].present? }

  private

  # authenticate_user! を手動で定義して Warden 認証を実行
  def authenticate_user!
    auth_header = request.headers["Authorization"]
    token = auth_header&.split(" ")&.last

    if token.present?
      begin
        # 1. JWT をデコードして payload（JTIやsub）を取得
        payload = Warden::JWTAuth::TokenDecoder.new.call(token)

        # 2. payload['sub']（ユーザーID）と payload['jti'] を使って DB から検索
        user = User.find_by(id: payload["sub"])

        # 3. DBの JTI とトークンの JTI が一致していれば認証成功（JTI失効チェック）
        if user && user.jti == payload["jti"]
          @current_user = user
        end
      rescue => e
        Rails.logger.error "JWT Auth Error: #{e.class} - #{e.message}"
      end
    end

    return if @current_user

    render json: {
      status: { code: 401, message: "Unauthorized. Please log in." }
    }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  protected

  def configure_permitted_parameters
    # 新規登録時に name を許可
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :bio, :bgm_url, :icon ])
    # アカウント更新時に name 等を許可
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :bio, :bgm_url, :icon ])
  end

  private

  def underscore_params_keys
    params.deep_transform_keys!(&:underscore)
  end

  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV["BASIC_AUTH_USER"] && password == ENV["BASIC_AUTH_PASSWORD"]
    end
  end
end
