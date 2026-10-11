class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Active Storage で画像を1枚紐付け(アイコン)
  has_one_attached :icon

  has_many :user_badges# 1人のUserは、複数のUserBadgeを持っている
  has_many :badges, through: :user_badges# UserBadgeを経由して、このUserに紐づいているBadgeを取得する

  # ユーザが持つ他モデルとか（project・カレンダー関係・今後フレンド機能とか）いったんフロントと解して現在のローカルユーザ情報がバックエンドに保存出来るまではコメントアウト
  # has_many :projects, dependent: :destroy
  # has_many :commits, through: :projects # projectに紐づくコミットもuserごとに紐づいているという内容(current_user.commitsで全件取れる)
  # has_many :calendar_memo, dependent: :destroy
  # has_many :day_schedule, dependent: :destroy

  # 保存前に id が空なら 8桁のランダム数字（例: 10000000 〜 99999999）を割り当てる
  before_validation :generate_numeric_id, on: :create

  # バリデーション
  validates :name, presence: true

  devise :database_authenticatable, # DBに保存されたパスワードでログイン
         :registerable, # ユーザー登録・変更など
         :validatable, # emailやpasswordのバリデーション
         :jwt_authenticatable,
         jwt_revocation_strategy: self

  private

  def generate_numeric_id
    return if id.present?

    loop do
      # 8桁のランダムな数字（10000000〜99999999）を生成
      random_id = SecureRandom.random_number(100_000_000..999_999_999)
      unless User.exists?(id: random_id)
        self.id = random_id
        break
      end
    end
  end
end
