# frozen_string_literal: true

# == Schema Information
#
# Table name: group_memberships
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  group_id   :integer          not null
#  role       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#
# Indexes
#
#  index_group_memberships_on_group_id  (group_id)
#  index_group_memberships_on_user_id   (user_id)
#

class GroupMembership < ApplicationRecord
  ALLOWED_ROLES = %w[committee member].freeze

  belongs_to :group
  belongs_to :user, autosave: true

  has_one :group_membership_request

  scope :committee, -> { where(role: "committee") }
  scope :normal, -> { where(role: "member") }

  after_initialize :set_default_role

  before_validation :replace_with_existing_user
  before_validation :invite_user_if_new
  after_create :delete_pending_gmrs, :approve_user

  validates :group_id, presence: true
  validates :role, inclusion: { in: ALLOWED_ROLES }
  validates :user, uniqueness: { scope: :group_id }
  validates_associated :user

  accepts_nested_attributes_for :user

  def self.allowed_roles_map
    ALLOWED_ROLES.map { |r| [I18n.t("group_membership_roles.#{r}"), r] }
  end

  def role=(val)
    self[:role] = val.downcase
  end

  protected

  def replace_with_existing_user
    if user
      existing = User.find_by(email: user.email)
      self.user = existing if existing
    end
    true
  end

  def invite_user_if_new
    # includes hack to trigger before_validation on user model
    user.invite! if user&.new_record? && (user&.valid? || true) && user&.email? && user&.full_name?
    true
  end

  def set_default_role
    self.role ||= "member"
  end

  def approve_user
    user.approve!
  end

  def delete_pending_gmrs
    GroupMembershipRequest.pending.where(user: user).where.not(id: group_membership_request&.id).delete_all
    true
  end
end
