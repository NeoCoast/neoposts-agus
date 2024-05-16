# frozen_string_literal: true

class Post < ApplicationRecord
  validates :title, :body, presence: true

  belongs_to :user

  before_validation :set_published_at, on: :create

  has_one_attached :image
  validate :validate_image_type

  private

  def validate_image_type
    return unless image.attached? && !image.content_type.in?(['image/png', 'image/jpeg'])

    errors.add(:image, 'Must be a PNG or a JPG file')
  end

  def set_published_at
    self.published_at = Time.now
  end
end
