# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password do
      Faker::Internet.password(min_length: Devise.password_length.min, max_length: Devise.password_length.min)
    end
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    nickname { Faker::Name.first_name }
    birthday { Faker::Date.birthday }

    trait :invalid do
      email { '' }
      nickname { '' }
    end
  end
end
