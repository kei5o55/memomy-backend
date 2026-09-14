require 'rails_helper'

RSpec.describe "Api::V1::Commits", type: :request do
  describe "POST /api/v1/projects/:project_id/commits (Commit作成)" do
    let!(:project) { create(:project) }

    context "正常なパラメータが送信された場合" do
      let(:valid_params) do
        {
          commit: {
            note: "ポモドーロ1セッション完了",
            duration_ms: "1500000",
            started_at: "2026-08-28T10:00:00.000Z",
            ended_at: "2026-08-28T10:25:00.000Z"
          }
        }
      end

      it "201 Created が返り、DBに Commit が 1 件追加されること" do
        expect {
          post "/api/v1/projects/#{project.id}/commits", params: valid_params
        }.to change(project.commits, :count).by(1)

        # 💡 コントローラーで status: :created を返している場合は :created に変更
        expect(response).to have_http_status(:created)
      end
    end

    context "存在しない project_id が URL に指定された場合" do
      let(:valid_params) do
        {
          commit: {
            note: "テスト"
          }
        }
      end

      it "404 Not Found が返り、エラーメッセージが含まれること" do
        post "/api/v1/projects/invalid-id-9999/commits", params: valid_params

        expect(response).to have_http_status(:not_found)

        json = JSON.parse(response.body)
        expect(json["error"]).to eq "Project not found or access denied"
      end
    end

    context "意図しないデータ(startedAt > endedAt)が送信された場合" do
      let(:invalid_time_params) do
        {
          commit: {
            note: "test",
            started_at: "2026-09-09T10:00:00Z",
            ended_at: "2026-09-01T11:00:00Z" # startedAt より過去の日時
          }
        }
      end

      it "422 Unprocessable Entity が返り、バリデーションエラーメッセージが含まれること" do
        post "/api/v1/projects/#{project.id}/commits", params: invalid_time_params

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Started at は終了日時（ended_at）より前の時間を指定してください")
      end
    end
  end

  describe "GET /api/v1/projects/:project_id/commits (Commit取得)" do
    let!(:project) { FactoryBot.create(:project) }
    let!(:commit1) { FactoryBot.create(:commit, project: project, note: "Commit 1") }
    let!(:commit2) { FactoryBot.create(:commit, project: project, note: "Commit 2") }

    it "200 OK が返り、指定した Project の Commit が取得できること" do
      get "/api/v1/projects/#{project.id}/commits"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json.length).to eq 2
      expect(json.map { |c| c["note"] }).to contain_exactly("Commit 1", "Commit 2")
    end

    it "存在しない project_id が指定された場合、404 Not Found が返ること" do
      get "/api/v1/projects/invalid-id-9999/commits"

      expect(response).to have_http_status(:not_found)

      json = JSON.parse(response.body)
      expect(json["error"]).to eq "Project not found"
    end

    it "project_idが指定されなかった場合,全てのコミットを取得できること" do
      get "/api/v1/commits"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json.length).to eq 2
      expect(json.map { |c| c["note"] }).to contain_exactly("Commit 1", "Commit 2")
    end
  end
end
