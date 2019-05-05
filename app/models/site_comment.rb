# frozen_string_literal: true

# == Schema Information
#
# Table name: site_comments
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  name         :string(255)
#  email        :string(255)
#  body         :text             not null
#  context_url  :string(255)
#  context_data :text
#  created_at   :datetime         not null
#  viewed_at    :datetime
#  deleted_at   :datetime
#

class SiteComment < ApplicationRecord
  acts_as_paranoid

  belongs_to :user

  after_initialize :set_user_details

  validates :body, presence: true
  validate :body_does_not_contain_spam
  validates :context_url, url: true
  normalize_attribute :context_url, with: :url

  def viewed?
    viewed_at
  end

  def viewed!
    self.viewed_at = Time.current
    save!
  end

  protected

  def set_user_details
    if user
      self.name = user.name
      self.email = user.email
    end
  end

  def body_does_not_contain_spam
    unless body !~ /(<a ([^>]+)>|<\/a>|\[url\]|\[url=|\[\/url\])/i
      errors.add(:body, 'The message cannot contain HTML.')
    end
  end
end
