# app/models/day_schedule.rb
class DaySchedule < ApplicationRecord
  # belongs_to :user
  belongs_to :project, optional: true # project_id が null でも許可する（プロジェクトに紐づく予定を作ろうと思ったけど、いらない説ある）

  before_validation :clamp_time_values

  validates :date, presence: true
  validates :title, presence: true

  private

  def clamp_time_values
    self.start_hour = (start_hour || 0).clamp(0, 23)
    self.start_minute = (start_minute || 0).clamp(0, 59)
    self.end_hour = (end_hour || 0).clamp(0, 23)
    self.end_minute = (end_minute || 0).clamp(0, 59)
  end

  def started_at_must_be_before_ended_at
    # 両方の値が存在するときだけ比較する（nil の際のカスケードエラー防止）
    return if started_at.blank? || ended_at.blank?

    if started_at > ended_at # 作業時間０は許容（画像やメモのみコミット）
      # errors.add(:対象属性, "エラーメッセージ")
      errors.add(:started_at, "は終了日時（ended_at）より前の時間を指定してください")
    end
  end
end
