# frozen_string_literal: true

# == Schema Information
#
# Table name: library_documents
#
#  id              :integer         not null, primary key
#  library_item_id :integer         not null
#  title           :string(255)     not null
#  file_uid        :string(255)
#  file_name       :string(255)
#  file_size       :integer
#

FactoryBot.define do
  factory :library_document, class: "Library::Document" do
    item { FactoryBot.build(:library_item) }
    sequence(:title) { |n| "Document #{n}" }
    file { Pathname.new(pdf_document_path) }

    after(:build) do |o|
      o.item.update(component: o)
    end

    factory :word_library_document do
      file { Pathname.new(word_document_path) }
    end

    after(:create) { |doc| doc.run_callbacks(:commit) }
  end
end
