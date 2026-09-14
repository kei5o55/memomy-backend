# spec/requests/api/v1/day_schedules_spec.rb
require 'rails_helper'

RSpec.describe "Api::V1::DaySchedules", type: :request do
  describe "GET /api/v1/day_schedules (一覧取得)" do
    it "200 OK が返り、スケジュール一覧が取得できること" do
      get "/api/v1/day_schedules"
    end
  end

  describe "POST /api/v1/day_schedules (作成・更新)" do
    context "不正なパラメータ（日付が未入力など）の場合" do
      let(:invalid_params) do
        {
          daySchedule: {
            targetDate: nil,
            notes: "無効なデータ"
          }
        }
      end

      it "422 Unprocessable Content が返り、エラーが含まれること" do
        post "/api/v1/day_schedules", params: invalid_params

        # 非推奨警告を避けるため 422 数値指定、または :unprocessable_content を用います
        expect(response).to have_http_status(422)

        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end
    end
  end
end
