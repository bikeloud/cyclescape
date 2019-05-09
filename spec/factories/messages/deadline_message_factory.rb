# frozen_string_literal: true

FactoryBot.define do
  factory :deadline_message do
    association :created_by, factory: :user
    association :message, factory: :message
    sequence(:title) { |n| "Imaginative deadline title #{n}" }
    sequence(:deadline) { |n| Time.now.in_time_zone + n.days }

    after(:build) do |o|
      o.thread = o.message.thread
      o.message.update(component: o)
    end
  end
end
