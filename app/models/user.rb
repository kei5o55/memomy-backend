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

  # ユーザが持つ他モデルとか（project・カレンダー関係・今後フレンド機能とか）
  has_many :projects, dependent: :destroy
  has_many :commits, through: :projects # projectに紐づくコミットもuserごとに紐づいているという内容(current_user.commitsで全件取れる)
  has_many :calendar_memo, dependent: :destroy
  has_many :day_schedule, dependent: :destroy

  # バリデーション
  validates :name, presence: true

  devise :database_authenticatable, # DBに保存されたパスワードでログイン
         :registerable, # ユーザー登録・変更など
         :validatable, # emailやpasswordのバリデーション
         :jwt_authenticatable,
         jwt_revocation_strategy: self
end
