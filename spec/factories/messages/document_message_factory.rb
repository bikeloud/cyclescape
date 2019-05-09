# frozen_string_literal: true

FactoryBot.define do
  factory :document_message do
    association :created_by, factory: :user
    association :message, factory: :message
    sequence(:title) { |n| "Imaginative file title #{n}" }
    file { Pathname.new(pdf_document_path) }

    after(:build) do |o|
      o.thread = o.message.thread
      o.message.update(component: o)
    end
  end
end
