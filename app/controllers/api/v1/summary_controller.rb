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
        projects = Project.all
        # ユーザーの全プロジェクトを取得（認証状況に応じて調整）
        # projects = current_user ? current_user.projects : Project.all

        # プロジェクトごとにクエリを投げると N+1 になるので、GROUP BY でまとめて集計する
        # （結果は { project_id => 値 } の Hash。コミットが無いプロジェクトはキー自体が無い）
        commits = Commit.where(project_id: projects.select(:id)).group(:project_id)
        total_ms_by_project = commits.sum(:duration_ms)
        count_by_project = commits.count
        last_commit_at_by_project = commits.maximum(:created_at)

        summaries = projects.map do |project|
          total_ms = total_ms_by_project[project.id] || 0
          {
            project_id: project.id,
            project_name: project.name,
            total_duration_ms: total_ms,
            total_minutes: (total_ms / 1000 / 60).to_i,
            session_count: count_by_project[project.id] || 0,
            last_commit_at: last_commit_at_by_project[project.id]
          }
        end

        render json: summaries, status: :ok
      end
end
