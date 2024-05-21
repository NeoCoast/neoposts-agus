# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :encrypted_password, :nickname, :first_name, :last_name, presence: true
  validates :nickname, uniqueness: { case_sensitive: false }

  has_one_attached :profile_picture
end
