# frozen_string_literal: true


class Issue < ApplicationRecord
  include Locatable
  include FakeDestroy
  include Taggable
  include Photo
  include BodyFormat

  searchable auto_index: false do
    text :title, :description, :tags_string, :id
    time :latest_activity_at, stored: true, trie: true
    latlon(:location) { Sunspot::Util::Coordinates.new(centre.y, centre.x) }
  end

  acts_as_voteable

  scope :by_score, lambda {
    joins(:votes).group(:id)
                 .having(Arel.sql("SUM(CASE votes.vote WHEN true THEN 1 WHEN false THEN -1 ELSE 0 END) > 0"))
                 .order(Arel.sql("SUM(CASE votes.vote WHEN true THEN 1 WHEN false THEN -1 ELSE 0 END) DESC"))
  }

  belongs_to :created_by, -> { with_deleted }, class_name: "User"
  belongs_to :planning_application
  has_many :threads, class_name: "MessageThread", after_add: :set_new_thread_defaults, inverse_of: :issue
  has_and_belongs_to_many :tags, join_table: "issue_tags"

  accepts_nested_attributes_for :threads

  validates :title, presence: true, length: { maximum: 80 }
  validates :description, presence: true
  validates :location, presence: true
  validates :size, numericality: { less_than: Geo::ISSUE_MAX_AREA }
  validates :created_by, presence: true
  validates :external_url, url: true

  default_scope { where(deleted_at: nil) }
  scope :by_most_recent, -> { order(created_at: :desc) }
  scope :preloaded,  -> { includes(:created_by, :tags) }
  scope :created_by, ->(user) { where(created_by_id: user) }

  after_commit :update_search
  normalize_attribute :external_url, with: :url

  class << self
    def after_date(date)
      where("coalesce(deadline, created_at) >= ?", date)
    end

    def before_date(date)
      where("coalesce(deadline, created_at) <= ?", date)
    end

    def email_upcomming_deadlines!
      where(deadline: Time.zone.now..1.day.from_now).includes(:threads).find_each do |issue|
        issue.threads.each do |thread|
          thread.email_subscribers.active.each do |subscriber|
            Notifications.upcoming_issue_deadline(subscriber, issue, thread).deliver_later
          end
        end
      end
    end
  end

  def latest_activity_at
    threads.includes(:messages).maximum("messages.updated_at")
  end

  def closed?
    closed = threads.pluck :closed
    !closed.empty? && closed.all?
  end

  def to_param
    "#{id}-#{title.parameterize}"
  end

  def formatted_deadline
    all_day ? deadline.to_date : deadline
  end

  protected

  # Association callback
  def set_new_thread_defaults(thread)
    thread.title ||= title if threads.count == 0
    thread.privacy ||= "public"
  end

  def storage_path
    "issue_photos"
  end

  def update_search
    SearchUpdater.update_type(self, :process_issue)
    true
  end
end

# == Schema Information
#
# Table name: issues
#
#  id                      :integer          not null, primary key
#  all_day                 :boolean          default(FALSE), not null
#  deadline                :datetime
#  deleted_at              :datetime
#  description             :text             not null
#  external_url            :text
#  location                :geometry({:srid= geometry, 4326
#  photo_name              :string
#  photo_uid               :string(255)
#  title                   :string(255)      not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  created_by_id           :integer          not null
#  planning_application_id :integer
#
# Indexes
#
#  index_issues_on_created_by_id            (created_by_id)
#  index_issues_on_location                 (location) USING gist
#  index_issues_on_planning_application_id  (planning_application_id)
#
# Foreign Keys
#
#  fk_rails_...  (planning_application_id => planning_applications.id)
#
