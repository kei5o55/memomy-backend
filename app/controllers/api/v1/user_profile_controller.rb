# app/controllers/api/v1/user_profile_controller.rb
# ログイン中ユーザー（current_user）のプロフィールを取得・更新する
module Api
  module V1
    class UserProfileController < ApplicationController
      # GET /api/v1/user_profile
      def show
        render json: profile_json(current_user), status: :ok
      end

      # PATCH /api/v1/user_profile
      # JSON（userProfile: {...}）で受け付ける
      # アイコンは未対応：active_storage_attachments.record_id が uuid 型で、bigint の users.id を紐付けられないため
      def update
        if current_user.update(user_profile_params)
          render json: profile_json(current_user), status: :ok
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      # email / password / id などの認証情報は更新させない
      def user_profile_params
        params.require(:user_profile).permit(:name, :bio, :bgm_url, sns_links: [])
      end

      def profile_json(user)
        {
          id: user.id,
          name: user.name,
          bio: user.bio,
          bgm_url: user.bgm_url,
          sns_links: user.sns_links,
          # Commit#image_url と同様に相対パスを返し、フロント側で HOST_URL と結合する
          icon: user.icon.attached? ? rails_blob_path(user.icon, only_path: true) : nil,
          created_at: user.created_at,
          updated_at: user.updated_at
        }
      end
    end
  end
end
