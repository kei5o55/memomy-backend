# app/controllers/api/v1/projects_controller.rb
module Api
  module V1
    class ProjectsController < ApplicationController
      # before_action :authenticate_user! # Devise-JWTによる認証チェック

      # GET /api/v1/projects
      def index
        # ログインユーザーのプロジェクトのみ取得
        # projects = current_user.projects.order(created_at: :desc)
        # commits = current_user.commits
        # sessions = current_user.work_sessions

        # いったんはログイン機能なしで全部のprojectsを
        projects = Project.all.order(created_at: :desc)

        # Commit や WorkSession モデルがある場合は全件取得（無ければ [] でOK）
        commits = defined?(Commit) ? Commit.all : []
        sessions = defined?(WorkSession) ? WorkSession.all : []

        render json: projects, status: :ok
        # json: {
        # projects: projects,
        # commits: commits,
        # sessions: sessions
        # }, status: :ok
      end

      # POST /api/v1/projects
      def create
        project = Project.new(project_params)

        if project.save
          render json: project, status: :created
        else
          render json: { errors: project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/projects/:id
      def destroy
        # project = current_user.projects.find(params[:id])
        project = Project.find(params[:id])
        project.destroy
        head :no_content
      end

      # PATCH /api/v1/projects/:id
      def update
        project = Project.find(params[:id])
        # 差分じゃなくて全部更新してるのか
        if project.update(project_params)
          render json: project, status: :ok
        else
          render json: { errors: project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def project_params # ユーザid等を許可しない
        # 1. フロントから届くキャメルケースのキー名を許可する
        p = params.require(:project).permit(
          :name,
          :memo,
          :completed,
          :due_date,
          :end_date,
          :target_hours,
          :pomodoro_work_minutes,
          :pomodoro_break_minutes
        )
        # {
        #  "project": {
        #    "name": "i4re",
        #    "completed": false,
        #    "targetHours": 1
        #  }
        # }
      end
    end
  end
end
