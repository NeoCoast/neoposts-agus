# frozen_string_literal: true

class Post < ApplicationRecord
  before_validation :set_published_at, on: :create

  validates :title, :body, presence: true
  validate :validate_image_type

  belongs_to :user
  has_one_attached :image
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy

  scope :ordered_by_publishing_date, -> { order(published_at: :desc) }
  scope :ordered_by_number_of_likes, -> { order(likes_count: :desc) }
  scope :ordered_by_trending, lambda {
    order(
      Arel.sql("posts.likes_count / EXP(DATE_PART('day', NOW() - posts.created_at) / 4.0) DESC")
    )
  }

  private

  def validate_image_type
    return unless image.attached? && !image.content_type.in?(['image/png', 'image/jpeg'])

    errors.add(:image, 'Must be a PNG or a JPG file')
  end

  def set_published_at
    self.published_at = Time.now
  end
end
