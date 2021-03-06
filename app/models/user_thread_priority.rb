# frozen_string_literal: true

class UserThreadPriority < ApplicationRecord
  PRIORITIES = { very_high: 10,
                 high: 8,
                 medium: 6,
                 low: 3,
                 very_low: 1,
                 nil: "" }.freeze

  belongs_to :user
  belongs_to :thread, class_name: "MessageThread", inverse_of: :user_priorities

  validates :priority, inclusion: 1..10, allow_nil: true
  validates :user, presence: true
  validates :thread, presence: true

  def self.priorities_map
    PRIORITIES.map { |p, v| [I18n.t("thread_priorities.#{p}"), v] }
  end

  def label
    PRIORITIES.key(priority)
  end
end

# == Schema Information
#
# Table name: user_thread_priorities
#
#  id         :integer          not null, primary key
#  priority   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  thread_id  :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_user_thread_priorities_on_thread_id_and_user_id  (thread_id,user_id)
#
