# spec/requests/api/v1/day_schedules_spec.rb
require 'rails_helper'

RSpec.describe "Api::V1::DaySchedules", type: :request do
  describe "GET /api/v1/day_schedules (一覧取得)" do
    it "200 OK が返り、スケジュール一覧が取得できること" do
      get "/api/v1/day_schedules"
    end
  end

  describe "POST /api/v1/day_schedules (作成)" do
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
