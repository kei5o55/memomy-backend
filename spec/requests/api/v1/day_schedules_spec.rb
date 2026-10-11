# spec/requests/api/v1/day_schedules_spec.rb
require 'rails_helper'

RSpec.describe "Api::V1::DaySchedules", type: :request do
  describe "GET /api/v1/day_schedules (一覧取得)" do
    it "200 OK が返り、スケジュール一覧が取得できること" do
      get "/api/v1/day_schedules"
    end
  end

  describe "POST /api/v1/day_schedules (作成)" do
    context "camelCase のルートキー・キーで JSON が送られてきた場合" do
      let(:camel_params) do
        {
          daySchedule: {
            date: "2026-10-11",
            title: "ラフ",
            startHour: 9,
            startMinute: 0,
            endHour: 10,
            endMinute: 30
          }
        }
      end

      it "snake_case に変換されて保存され、レスポンスは snake_case のキーで返ること" do
        post "/api/v1/day_schedules", params: camel_params, as: :json

        expect(response).to have_http_status(:created)

        schedule = DaySchedule.last
        expect([ schedule.start_hour, schedule.end_hour, schedule.end_minute ]).to eq [ 9, 10, 30 ]

        json = JSON.parse(response.body)
        expect(json).to include("start_hour" => 9, "end_minute" => 30)
      end
    end

    context "不正なパラメータ（日付が未入力など）の場合" do
      let(:invalid_params) do
        {
          day_schedule: {
            target_hours: nil,
            notes: "無効なデータ"
          }
        }
      end

      it "422 Unprocessable Content が返り、エラーが含まれること" do
        post "/api/v1/day_schedules", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end
    end
  end

  describe "DELETE /api/v1/day_schedules (削除)" do
    context "存在しないスケジュールIDの場合" do
      it "404 Not Found が返り、エラーメッセージが含まれること" do
        delete "/api/v1/day_schedules/invalid-id-9999"

        expect(response).to have_http_status(:not_found)

        json = JSON.parse(response.body)
        expect(json["error"]).to eq "指定されたスケジュールが見つかりません"
      end
    end
  end
end
