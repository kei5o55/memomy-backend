class Api::V1::SummaryController < ApplicationController
    # GET /api/v1/summary/project_id/:id
      def project
        # 認証なしで全 Project から ID 検索
        project = Project.find(params[:id])
        commits = project.commits
        total_ms = commits.sum(:duration_ms) || 0

        render json: {
          project_id: project.id,
          project_name: project.name,
          total_duration_ms: total_ms,
          total_minutes: (total_ms / 1000 / 60).to_i,
          session_count: commits.count,
          last_commit_at: commits.maximum(:created_at)
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Project not found" }, status: :not_found
      end

      # GET /api/v1/summary/project (全プロジェクト一括取得)
      def project_all_summary
        # 認証なしで DB 内の全プロジェクトとそのコミットを一括取得
        projects = Project.includes(:commits).all
        # ユーザーの全プロジェクトを取得（認証状況に応じて調整）
        # projects = current_user ? current_user.projects : Project.all

        summaries = projects.map do |project|
          total_ms = project.commits.sum(:duration_ms) || 0
          {
            project_id: project.id,
            project_name: project.name,
            total_duration_ms: total_ms,
            total_minutes: (total_ms / 1000 / 60).to_i,
            session_count: project.commits.count,
            last_commit_at: project.commits.maximum(:created_at)
          }
        end

        render json: summaries, status: :ok
      end
end
