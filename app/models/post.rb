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
  scope :filtered_by_date, lambda { |date_criteria|
    where('published_at >= ?', date_criteria) if date_criteria.present?
  }
  scope :filtered_by_text, lambda { |text_criteria|
    if text_criteria.present?
      joins(:user).where(
        Arel.sql("CONCAT(users.first_name, ' ', users.last_name) ILIKE :search OR
                  users.nickname ILIKE :search OR
                  title ILIKE :search OR
                  body ILIKE :search"),
        search: "%#{text_criteria}%"
      )
    end
  }
  scope :filter_and_sort, lambda { |date_criteria, text_criteria, sort_criteria|
    filtered_by_date(date_criteria).filtered_by_text(text_criteria).public_send("ordered_by_#{sort_criteria}")
  }

  private

  def validate_image_type
    return unless image.attached? && !image.content_type.in?(['image/png', 'image/jpeg'])

    errors.add(:image, 'Must be a PNG or a JPG file')
  end

  def set_published_at
    self.published_at ||= Time.now
  end
end
