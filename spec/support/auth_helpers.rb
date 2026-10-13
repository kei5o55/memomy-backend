# リクエストスペックで JWT 付きのヘッダーを作るヘルパー
module AuthHelpers
  def auth_user
    @auth_user ||= create(:user)
  end

  def auth_headers(user = auth_user)
    token, _payload = Warden::JWTAuth::UserEncoder.new.call(user, Devise::Mapping.find_scope!(user), nil)
    { "Authorization" => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
