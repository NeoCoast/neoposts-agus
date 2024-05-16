# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    encrypted_password { Faker::Internet.password }
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    birthday { Faker::Date.birthday }
  end
end
