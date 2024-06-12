# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :nickname, :first_name, :last_name, :birthday, presence: true
  validates :nickname, uniqueness: { case_sensitive: false }
  validate :validate_image_type

  has_one_attached :profile_picture
  has_many :posts, dependent: :destroy

  has_many :active_relationships, class_name: 'FollowRelationship',
                                  foreign_key: 'follower_id',
                                  dependent: :destroy
  has_many :passive_relationships, class_name: 'FollowRelationship',
                                   foreign_key: 'followed_id',
                                   dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  def full_name
    "#{first_name} #{last_name}"
  end

  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id)&.destroy
  end

  def following?(other_user)
    following.include?(other_user)
  end

  private

  def validate_image_type
    return unless profile_picture.attached? && !profile_picture.content_type.in?(['image/png', 'image/jpeg'])

    errors.add(:profile_picture, 'Must be a PNG or a JPG file')
  end
end
