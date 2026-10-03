# app/controllers/api/v1/sync_controller.rb
# idbのデータを一括以降する奴（普段使いしない）
module Api
  module V1
    class SyncController < ApplicationController
      def import
        projects_data = params[:projects] || []
        commits_data = params[:commits] || []

        imported_projects_count = 0
        imported_commits_count = 0

        ActiveRecord::Base.transaction do
          # 1. プロジェクトを先にすべて保存する
          projects_data.each do |p_data|
            project = Project.find_or_initialize_by(id: p_data[:id])
            project.assign_attributes(
              name: p_data[:name],
              memo: p_data[:memo],
              pomodoro_work_minutes: p_data[:pomodoro_work_minutes],
              pomodoro_break_minutes: p_data[:pomodoro_break_minutes],
              created_at: parse_time(p_data[:created_at]) || Time.current
            )
            project.save!
            imported_projects_count += 1
          end

          # 2. コミットのインポート
          commits_data.each do |c_data|
            # 💡 該当するプロジェクトが DB に存在するかチェック
            project_exists = Project.exists?(id: c_data[:project_id])

            unless project_exists
              # 参照先プロジェクトが存在しない不整合データはログを出してスキップ（またはエラー回避）
              Rails.logger.warn("Skipping commit #{c_data[:id]} because Project #{c_data[:project_id]} does not exist.")
              next
            end

            commit = Commit.find_or_initialize_by(id: c_data[:id])

            ended_at = parse_time(c_data[:ended_at]) || Time.current
            duration_ms = c_data[:duration_ms].to_i

            started_at = parse_time(c_data[:started_at])
            started_at ||= (ended_at - (duration_ms / 1000.0))

            commit.assign_attributes(
              project_id: c_data[:project_id],
              duration_ms: duration_ms,
              started_at: started_at,
              ended_at: ended_at,
              note: c_data[:note]
            )

            if c_data[:image_base64].present?
              attach_base64_image(commit, c_data[:image_base64])
            end

            commit.save!
            imported_commits_count += 1
          end
        end

        render json: {
          status: "success",
          imported_projects_count: imported_projects_count,
          imported_commits_count: imported_commits_count
        }, status: :ok

      rescue => e
        render json: { status: "error", message: e.message }, status: :unprocessable_entity
      end

      private

      def parse_time(val)
        return nil if val.blank?

        if val.is_a?(Numeric) || val.to_s.match?(/\A\d+\z/)
          Time.at(val.to_i / 1000.0)
        else
          Time.zone.parse(val.to_s)
        end
      rescue
        nil
      end

      def attach_base64_image(commit, base64_data)
        return unless base64_data.start_with?("data:image")

        header, data = base64_data.split(",")
        mime_type = header.match(%r{data:(.*?);base64})[1]
        extension = mime_type.split("/").last
        decoded_data = Base64.decode64(data)

        commit.image.attach(
          io: StringIO.new(decoded_data),
          filename: "commit_#{commit.id}.#{extension}",
          content_type: mime_type
        )
      end
    end
  end
end
