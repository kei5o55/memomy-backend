# spec/requests/api/v1/projects_spec.rb
require 'rails_helper'

RSpec.describe "Api::V1::Projects", type: :request do
  describe "GET /api/v1/projectc (ロード)" do
    it "200 OK が返り、プロジェクト一覧が取得できること" do
      create(:project)
      create(:project)

      get "/api/v1/projects"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json.length).to eq(2)
    end
  end

  describe "POST /api/v1/projects (新規作成)" do
    context "正常なパラメータ（文字列の数値や日付含む）が送られてきた場合" do
      let(:valid_params) do
        {
          project: {
            name: "COMITIA新刊",
            due_date: "2026-08-29",
            completed: false,
            memo: "表紙ラフ作成から",
            target_hours: "10",                # フロントからは文字列で届く
            pomodoro_work_minutes: "25",
            pomodoro_break_minutes: "5"
          }
        }
      end

      it "201 Created が返り、DBにプロジェクトが1件追加されること" do
        expect {
          post "/api/v1/projects", params: valid_params
        }.to change(Project, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it "Rails側で Date型 や Integer型 に正しく自動変換されて保存されること" do
        post "/api/v1/projects", params: valid_params

        created_project = Project.last

        # 日付が Date オブジェクトに変換されているか
        expect(created_project.due_date).to eq Date.parse("2026-08-29")
        # 文字列 "10" が数値の 10 として保存されているか
        expect(created_project.target_hours).to eq 10
        expect(created_project.pomodoro_work_minutes).to eq 25
      end

      it "レスポンスの JSON に作成されたデータが含まれていること" do
        post "/api/v1/projects", params: valid_params

        json = JSON.parse(response.body)
        expect(json["name"]).to eq "COMITIA新刊"
      end
    end

    context "名前が空の場合 (不正なパラメータ)" do
      let(:invalid_params) do
        {
          project: {
            name: "",
            completed: false,
            target_hours: "10"
          }
        }
      end

      it "DBに追加されず、422 Unprocessable Entity とエラーメッセージが返ること" do
        expect {
          post "/api/v1/projects", params: invalid_params
        }.not_to change(Project, :count)

        expect(response).to have_http_status(:unprocessable_content)

        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end
    end

    context "想定しない数値（マイナスの目標時間）が送信された場合" do
      let(:invalid_params) do
        {
          project: {
            name: "ire",
            completed: false,
            target_hours: "-1"
          }
        }
      end

      it "DBに追加されず、422 Unprocessable Entity とエラーメッセージが返ること" do
        expect {
          post "/api/v1/projects", params: invalid_params
        }.not_to change(Project, :count)

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end
    end
  end

  describe "PATCH /api/v1/projects(更新)" do
    let(:project) { create(:project) }
    context "存在しないproject_idが送信された場合" do
      it "404 Not Found が返ること" do
        patch "/api/v1/projects/999999", params: { project: { name: "更新テスト" } }

        expect(response).to have_http_status(:not_found)
      end
    end
    context "存在するproject_idが送信された場合" do
      it "正しく更新されること" do
        patch "/api/v1/projects/#{project.id}", params: { project: { name: "更新テスト" } }

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["name"]).to eq("更新テスト")
      end
    end
    context "想定しない数値が送信された場合" do
      it "422 Unprocessable Entity が返ること(数値マイナス)" do
        patch "/api/v1/projects/#{project.id}", params: { project: { target_hours: "-1" } }

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present

        patch "/api/v1/projects/#{project.id}", params: { project: { name: "" } }

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end
      it "422 Unprocessable Entity が返ること(名前空欄)" do
        patch "/api/v1/projects/#{project.id}", params: { project: { name: "" } }

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end
    end
  end

  describe "DELETE /api/v1/projects(削除)" do
    let(:project) { create(:project) }
    context "存在しないproject_idが送信された場合" do
      it "404 Not Found が返ること" do
        delete "/api/v1/projects/999999"

        expect(response).to have_http_status(:not_found)
      end
    end
    context "存在するproject_idが送信された場合" do
      it "正しく削除されること" do
        delete "/api/v1/projects/#{project.id}"

        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
