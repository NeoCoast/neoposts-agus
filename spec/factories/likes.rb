# frozen_string_literal: true

FactoryBot.define do
  factory :like do
    user

    trait :likeable_type_post do
      association :likeable, factory: :post
    end

    trait :likeable_type_comment do
      association :likeable, factory: :comment_of_post
    end
  end
end
