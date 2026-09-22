module Api
  module V1
    class CommitsController < ApplicationController
      # Active Storage の URL 生成ヘルパーを使用可能にする
      include Rails.application.routes.url_helpers

      # 認証機能を追加する場合は有効化
      # before_action :authenticate_user!

      # GET /api/v1/projects/:project_id/commits
      def index
        commits = if params[:project_id].present?
                    # プロジェクト指定がある場合
                    project = Project.find(params[:project_id])
                    project.commits
        else
                    # 全件取得する場合
                    Commit.all
        end

        # N+1 防止 & 降順ソート
        commits = commits.with_attached_image.order(created_at: :desc)

        render json: commits.map { |commit| commit_response(commit) }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Project not found" }, status: :not_found
      end

      # POST /api/v1/projects/:project_id/commits
      def create
        # 1. Project ID から検索
        project = Project.find(params[:project_id])

        # project.commits.build(commit_params) 時に project_id は自動設定される
        commit = project.commits.build(commit_params)

        # commit.user = current_user

        if commit.save
          render json: commit_response(commit), status: :created 
        else
          render json: { errors: commit.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Project not found or access denied" }, status: :not_found
      end

      # DELETE /api/v1/commits/:id
      def destroy
        commit = Commit.find(params[:id])
        commit.destroy
        head :no_content #
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Commit not found" }, status: :not_found
      end

      private

      def commit_params
        #  フロントから届くパラメータを許可（projectId は URL 側で担保されるため除外）
        p = params.require(:commit).permit(
          :note,
          :project_id,
          :duration_ms,
          :started_at,
          :ended_at,
          :image
        )
        # {
        #  "commit": {
        #    "startedAt": "2026-09-09T10:00:00Z",
        #    "endedAt": "2026-09-09T11:00:00Z",
        #    "durationMs": 3600000,
        #    "note": "Postmanからのテスト送信です"
        #  }
        # }
      end

      def commit_response(commit)# キャメルケースにマッピング
        {
          id: commit.id,
          projectId: commit.project_id,
          note: commit.note,
          startedAt: commit.started_at,
          endedAt: commit.ended_at,
          durationMs: commit.duration_ms,
          # ActiveStorage の添付有無を判定してパス/URLを生成
          image: commit.image.attached? ? rails_blob_path(commit.image, only_path: true) : nil
        }
      end
    end
  end
end
