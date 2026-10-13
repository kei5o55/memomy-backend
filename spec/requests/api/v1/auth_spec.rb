require 'rails_helper'

RSpec.describe "Api::V1 認証", type: :request do
  describe "認証が必要な API" do
    it "トークンなしでは 401 が返ること" do
      get "/api/v1/projects"

      expect(response).to have_http_status(:unauthorized)
    end

    it "不正なトークンでは 401 が返ること" do
      get "/api/v1/projects", headers: { "Authorization" => "Bearer invalid-token" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "有効なトークンでは 200 が返ること" do
      get "/api/v1/projects", headers: auth_headers

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/v1/login (ログイン)" do
    let!(:user) { create(:user, email: "login@example.com", password: "password123") }

    it "正しい資格情報なら Authorization ヘッダーにトークンが返り、そのトークンで API を使えること" do
      post "/api/v1/login", params: { user: { email: "login@example.com", password: "password123" } }, as: :json

      expect(response).to have_http_status(:ok)
      token = response.headers["Authorization"]
      expect(token).to start_with("Bearer ")

      get "/api/v1/me", headers: { "Authorization" => token }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).dig("user", "id")).to eq(user.id)
    end

    it "パスワードが違えば 401 が返ること" do
      post "/api/v1/login", params: { user: { email: "login@example.com", password: "wrong" } }, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(response.headers["Authorization"]).to be_nil
    end
  end

  describe "POST /api/v1/signup (新規登録)" do
    it "ユーザーが作成され、トークンが返ること" do
      expect {
        post "/api/v1/signup", params: {
          user: { name: "新規", email: "new@example.com", password: "password123", passwordConfirmation: "password123" }
        }, as: :json
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.headers["Authorization"]).to start_with("Bearer ")
    end
  end

  describe "DELETE /api/v1/logout (ログアウト)" do
    it "ログアウト後は同じトークンが使えなくなること" do
      headers = auth_headers

      delete "/api/v1/logout", headers: headers
      expect(response).to have_http_status(:ok)

      get "/api/v1/projects", headers: headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "トークンなしでは 401 が返ること" do
      delete "/api/v1/logout"

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
