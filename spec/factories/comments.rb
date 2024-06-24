# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    user

    trait :commentable_type_post do
      association :commentable, factory: :post
    end

    trait :commentable_type_comment do
      association :commentable, factory: :comment
    end

    trait :with_content do
      content { Faker::Quote.matz }
    end

    trait :without_content do
      content { '' }
    end

    factory :comment_of_post,      traits: %i[commentable_type_post with_content]
    factory :comment_of_comment,   traits: %i[commentable_type_comment with_content]
  end
end
