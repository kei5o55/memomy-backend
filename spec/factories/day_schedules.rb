# spec/factories/day_schedules.rb
FactoryBot.define do
  factory :day_schedule do
    sequence(:date) { |n| Date.current + n.days }
    title { "テストコメント" }
    start_hour {"1"}
    start_minute{"0"}
    end_hour{"2"}
    end_minute{"0"}
  end
end
