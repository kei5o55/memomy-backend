require 'rails_helper'

RSpec.describe "Api::V1::UserProfile", type: :request do
  describe "GET /api/v1/user_profile (プロフィール取得)" do
    it "ログイン中ユーザーのプロフィールが snake_case で返ること" do
      auth_user.update!(name: "自分", bio: "自己紹介", bgm_url: "https://example.com/bgm", sns_links: [ "https://x.com/foo" ])
      create(:user, name: "他人")

      get "/api/v1/user_profile", headers: auth_headers

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json.keys).to contain_exactly("id", "name", "bio", "bgm_url", "sns_links", "icon", "created_at", "updated_at")
      expect(json["id"]).to eq(auth_user.id)
      expect(json["name"]).to eq("自分")
      expect(json["bio"]).to eq("自己紹介")
      expect(json["bgm_url"]).to eq("https://example.com/bgm")
      expect(json["sns_links"]).to eq([ "https://x.com/foo" ])
      expect(json["icon"]).to be_nil
    end

    it "email などの認証情報は含まれないこと" do
      get "/api/v1/user_profile", headers: auth_headers

      json = JSON.parse(response.body)
      expect(json).not_to include("email", "encrypted_password", "jti")
    end

    it "トークンなしでは 401 が返ること" do
      get "/api/v1/user_profile"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PATCH /api/v1/user_profile (プロフィール更新)" do
    context "camelCase の JSON が送られてきた場合" do
      let(:camel_params) do
        {
          userProfile: {
            name: "新しい名前",
            bio: "イラスト描いてます",
            bgmUrl: "https://example.com/bgm",
            snsLinks: [ "https://x.com/foo", "https://example.com" ]
          }
        }
      end

      it "ログイン中ユーザーのプロフィールが更新され、snake_case で返ること" do
        patch "/api/v1/user_profile", params: camel_params, as: :json, headers: auth_headers

        expect(response).to have_http_status(:ok)

        auth_user.reload
        expect(auth_user.name).to eq("新しい名前")
        expect(auth_user.bio).to eq("イラスト描いてます")
        expect(auth_user.bgm_url).to eq("https://example.com/bgm")
        expect(auth_user.sns_links).to eq([ "https://x.com/foo", "https://example.com" ])

        json = JSON.parse(response.body)
        expect(json.keys).to contain_exactly("id", "name", "bio", "bgm_url", "sns_links", "icon", "created_at", "updated_at")
        expect(json["id"]).to eq(auth_user.id)
        expect(json["icon"]).to be_nil
      end
    end

    it "snsLinks に空配列を送るとリンクを全削除できること" do
      auth_user.update!(sns_links: [ "https://x.com/foo" ])

      patch "/api/v1/user_profile", params: { userProfile: { snsLinks: [] } }, as: :json, headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(auth_user.reload.sns_links).to eq([])
    end

    it "アイコンは受け付けず無視されること（record_id が uuid 型のため未対応）" do
      patch "/api/v1/user_profile",
            params: { userProfile: { name: "名前", icon: fixture_file_upload("test_image.png", "image/png") } },
            headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(auth_user.reload.icon).not_to be_attached
    end

    it "email やパスワードは更新されないこと" do
      original_email = auth_user.email

      patch "/api/v1/user_profile",
            params: { userProfile: { name: "名前", email: "hacked@example.com", password: "changed123" } },
            as: :json, headers: auth_headers

      expect(response).to have_http_status(:ok)
      auth_user.reload
      expect(auth_user.email).to eq(original_email)
      expect(auth_user.valid_password?("password123")).to be true
    end

    it "他のユーザーのプロフィールは変更されないこと" do
      other = create(:user, name: "他人")

      patch "/api/v1/user_profile", params: { userProfile: { name: "変更" } }, as: :json, headers: auth_headers

      expect(other.reload.name).to eq("他人")
    end

    it "name が空なら 422 が返ること" do
      patch "/api/v1/user_profile", params: { userProfile: { name: "" } }, as: :json, headers: auth_headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to be_present
    end

    it "トークンなしでは 401 が返ること" do
      patch "/api/v1/user_profile", params: { userProfile: { name: "変更" } }, as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
