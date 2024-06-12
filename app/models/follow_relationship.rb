# frozen_string_literal: true

class FollowRelationship < ApplicationRecord
  validates :follower_id, presence: true
  validates :followed_id, presence: true
  validates :follower_id, uniqueness: { scope: :followed_id }
  validate :cannot_follow_themselves

  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'

  private

  def cannot_follow_themselves
    return unless follower_id == followed_id

    errors.add(:followed_id, 'cannot be the same as follower_id')
  end
end
