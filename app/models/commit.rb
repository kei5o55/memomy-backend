# app/models/commit.rb
class Commit < ApplicationRecord
  belongs_to :project
  # いったんユーザ別を無しに
  # belongs_to :user
  has_one_attached :image # コミット用画像を１つモテる

  validates :duration_ms, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  # 通常の存在チェックなど
  validates :started_at, presence: true
  validates :ended_at, presence: true

  # カスタムバリデーションの登録
  validate :started_at_must_be_before_ended_at

  # フロントエンドに返す JSON の構造を整える
  def as_json(options = {})
    super(options.merge(
      methods: [ :image_url ],
      except: [ :created_at, :updated_at ]
    ))
  end

  def image_url
    return nil unless image.attached?

    # only_path: true を機能させるため、ActiveStorage::Current にダミーの host をセット
    ActiveStorage::Current.url_options = { host: "localhost", only_path: true }

    # rails_blob_path で相対パスを取得
    Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
  rescue StandardError
    nil
  end

  private

  def started_at_must_be_before_ended_at
    # 両方の値が存在するときだけ比較する（nil の際のカスケードエラー防止）
    return if started_at.blank? || ended_at.blank?

    if started_at > ended_at
      # errors.add(:対象属性, "エラーメッセージ")
      errors.add(:started_at, "は終了日時（ended_at）より前の時間を指定してください")
    end
  end
end
