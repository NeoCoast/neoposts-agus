# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :nickname, :first_name, :last_name, :birthday, presence: true
  validates :nickname, uniqueness: { case_sensitive: false }
  validate :validate_image_type

  has_one_attached :profile_picture
  has_many :posts

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def validate_image_type
    return unless profile_picture.attached? && !profile_picture.content_type.in?(['image/png', 'image/jpeg'])

    errors.add(:profile_picture, 'Must be a PNG or a JPG file')
  end
end
