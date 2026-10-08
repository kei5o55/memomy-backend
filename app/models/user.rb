class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Active Storage で画像を1枚紐付け(アイコン)
  has_one_attached :icon

  has_many :user_badges#1人のUserは、複数のUserBadgeを持っている
  has_many :badges, through: :user_badges#UserBadgeを経由して、このUserに紐づいているBadgeを取得する
  # バリデーション
  validates :name, presence: true

  devise :database_authenticatable, # DBに保存されたパスワードでログイン
         :registerable, # ユーザー登録・変更など
         :validatable, # emailやpasswordのバリデーション
         :jwt_authenticatable,
         jwt_revocation_strategy: self
end
