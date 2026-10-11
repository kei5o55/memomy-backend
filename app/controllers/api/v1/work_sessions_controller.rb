module Api
  module V1
    class WorkSessionsController < ApplicationController
      def index
        # work_sessions = WorkSession.all.order(created_at: :desc)
        # render json: work_sessions, status: :ok
        render json: {
          status: "ok",
          message: "Rails API is connected successfully!",
          timestamp: Time.current
        }, status: :ok
      end

      def create
        work_session = WorkSession.new(work_session_params)

        if work_session.save
          render json: work_session, status: :created
        else
          render json: { errors: work_session.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def work_session_params
        params.require(:work_session).permit(
          :project_id,
          :started_at,
          :ended_at,
          :note,
          :status,
          :pomodoro_count
        )
      end
    end
  end
end
