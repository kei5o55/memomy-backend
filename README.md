[![Backend CI](https://github.com/kei5o55/memomy-backend/actions/workflows/ci.yml/badge.svg)](https://github.com/kei5o55/memomy-backend/actions/workflows/ci.yml)
## 概要
作業記録ツールのREST APIバックエンド

## 現時点での実装内容

* 各Controllerにおける`GET` / `POST` / `DELETE` / `PATCH`処理の実装
* RSpecを用いたテストコードの実装
* `migration`や`model`など、Railsの規約に沿ったデータベース設計・実装
* Render.comへのバックエンドAPIのデプロイ
* Vercel上のフロントエンドとの接続・疎通確認

  * 本番環境でフロントエンドからバックエンドAPIを利用できる状態まで構築

### 今後実装予定

* 認証・認可機能の実装
* ユーザーごとのデータ管理
* 認証状態・権限に応じたController処理


## 工夫
### 画像URLの相対パス化による環境依存の排除
  - **課題**：バックエンド側で絶対パス(`https://locahost3000/`)を生成すると、将来的な本番環境へのデプロイ時にめんどくさくなりそう
  - **工夫**：Active Storageのレスポンスを相対パス（`/rails/active_storage/`)で返却、フロント側でurlと結合処理を施すことで環境によってバックエンド側のコード書き換えや不具合が発生しない柔軟な設計とした

### テストコード
- 現時点での使用フロー上考えられるうる呼び出され方を網羅（したつもり）
- 例外処理をとくに意識した実装をしました


### ID 設計

本プロジェクトでは、フロントエンド（Next.js）およびバックエンド（Rails API / PostgreSQL）間での主キー（ID）管理において、**バックエンド主導の UUID 採番** を採用しています。

* **データベース設計:** 
  PostgreSQL の `pgcrypto` を使用し、`id: :uuid, default: -> { "gen_random_uuid()" }` を設定。
* **データフロー:**
  -  **新規作成 (`POST /api/v1/projects`):**
     * クライアントは `id` を含めずにリクエストボディを送信。
     * PostgreSQL 側で不可逆かつユニークな UUID が自動発番される。
     * レスポンスに含まれる `id`（UUID）をクライアント側で取得・保持する。
  -  **更新・削除 (`PATCH` / `DELETE /api/v1/projects/:id`):**
     * クライアントは保持している `id` を **パスパラメータ（URL）** に埋め込んで送信。

#### この設計を採用した理由
* **セキュリティ・整合性の担保:** データの発番・管理権限をデータベース（信頼できる環境）に一元化し、クライアント側からの不正な ID 注入を防ぐため。
* **データ競合の防止:** 自動採番（Auto Increment Integer）ではなく UUID を採用することで、ID 推測攻撃を防ぎ、将来的なマルチデバイス同期やデータ統合時の ID 衝突リスクを排除するため。

###  認証・認可と Strong Parameters の分離 (今後の拡張性)

将来的に認証認可を実装した場合、リクエスト処理における「属性レベルの制御」と「リソース権限の検証」のレイヤーを明確に分離して実装予定しています。

* **Strong Parameters（属性レベルの保護）:**
  * 新規作成・更新ともに **リクエストボディでの `:id` の受け取り（許可）は行わない**。
  * 主キー（`id`）の書き換えを遮断し、マスアサインメント脆弱性を防止。
* **JWT 認証 & スコープ制限）:**
  * リソースの特定・更新は、URLのパスパラメータ `params[:id]` を利用。
  * 単に `Project.find(params[:id])` で検索するのではなく、必ずログインユーザーのスコープ制限（`current_user.projects.find(params[:id])`）を噛ませて検索を実施。

```ruby
# app/controllers/api/v1/projects_controller.rb

def update
  # 1. 認可: ログインユーザーの所有リソースからのみ params[:id] で特定
  @project = current_user.projects.find(params[:id])

  # 2. 更新: Strong Parameters 経由で許可された属性のみ更新
  if @project.update(project_params)
    render json: @project, status: :ok
  else
    render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
  end
end

private

def project_params
  # :id は許可せず、安全な属性のみ定義
  params.require(:project).permit(
    :name,
    :completed,
    :due_date,
    :end_date,
    :memo,
    :pomodoro_work_minutes,
    :pomodoro_break_minutes,
    :target_hours
  )
end
```

## その他注意点とか

Dockerを用いた開発経験

- モデルを作るとき:`docker compose exec web rails g model Task title:string status:integer`

- マイグレーション（DB反映）をするとき:`docker compose exec web rails db:migrate`

のように、従来のrailsコマンドの先頭に`docker compose exec web`を付ける。

wslを使用しているため、Docker側で Setting → Resource → WSL integration から設定をオンに


rails new を実行するとファイルの所有者がrootになり保存できなくなる場合がある。なんか色々変になって保存できなくなったときは

`sudo chown -R $USER:$USER ~/worklog/progress-recorder-backend`

## test
- ① 全てのテストを実行する場合
  `docker compose exec web bundle exec rspec`

- ② モデルテストだけ実行する場合
  `docker compose exec web bundle exec rspec spec/models/project_spec.rb`

- ③ APIリクエストテストだけ実行する場合
  `docker compose exec web bundle exec rspec spec/requests/api/v1/projects_spec.rb`

- ④ 特定の行（例: 15行目の it ブロック）だけピンポイントで実行する場合
  
  `docker compose exec web bundle exec rspec spec/requests/api/v1/projects_spec.rb:15`


#### rubocop

`docker compose exec web bundle exec rubocop -a`

で変更を反映
