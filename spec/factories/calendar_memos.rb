# spec/factories/calendar_memos.rb
FactoryBot.define do
  factory :calendar_memo do
    sequence(:date) { |n| Date.current + n.days }
    text { "テストだよぅ" }
  end
end
