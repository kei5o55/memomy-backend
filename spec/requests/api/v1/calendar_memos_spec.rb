# spec/requests/api/v1/calendar_memos_spec.rb
require 'rails_helper'

RSpec.describe "Api::V1::CalendarMemos", type: :request do
  # テストデータの作成（FactoryBotを想定。未導入の場合は CalendarMemo.create! に置き換えてください）
  let!(:calendar_memos) { create_list(:calendar_memo, 3) }
  let(:calendar_memo) { calendar_memos.first }

  describe "GET /api/v1/calendar_memos (一覧取得)" do
    it "カレンダーメモの一覧を取得し、ステータス 200 (OK) を返すこと" do
      get api_v1_calendar_memos_path

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
    end
  end

  describe "POST /api/v1/calendar_memos (新規作成)" do
    context "有効なパラメータの場合" do
      let(:valid_params) do
        {
          calendar_memo: {
            date: "2026-09-08",
            text: "テストメモ"
          }
        }
      end

      it "新しいカレンダーメモが作成され、ステータス 201 (Created) を返すこと" do
        expect {
          post api_v1_calendar_memos_path, params: valid_params
        }.to change(CalendarMemo, :count).by(1)

        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)
        expect(json["text"]).to eq("テストメモ")
        expect(json["date"]).to eq("2026-09-08")
      end
    end

    context "無効なパラメータの場合" do
      let(:invalid_params) do
        {
          calendar_memo: {
            date: nil, # バリデーションエラーになる値
            text: ""
          }
        }
      end

      it "作成に失敗し、ステータス 422 (Unprocessable Entity) とエラーメッセージを返すこと" do
        expect {
          post api_v1_calendar_memos_path, params: invalid_params
        }.not_to change(CalendarMemo, :count)

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json).to have_key("errors")
      end
    end
  end

  describe "DELETE /api/v1/calendar_memos/:id (削除)" do
    context "存在するデータの場合" do
      it "データが削除され、ステータス 204 (No Content) を返すこと" do
        expect {
          delete api_v1_calendar_memo_path(calendar_memo)
        }.to change(CalendarMemo, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "存在しないデータの場合" do
      it "ステータス 404 (Not Found) を返すこと" do
        delete api_v1_calendar_memo_path(id: 999999)

        expect(response).to have_http_status(:not_found)

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("指定されたメモが見つかりません")
      end
    end
  end
end
