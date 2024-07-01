# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    title { Faker::Book.title }
    body { Faker::Quote.matz }
    published_at { Faker::Date.in_date_period }
    likes_count { Faker::Number.between(from: 1, to: 100) }
    user

    trait :invalid do
      title { '' }
      body { '' }
      published_at { '' }
      user { nil }
    end
  end
end
