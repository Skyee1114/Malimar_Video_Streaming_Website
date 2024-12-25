require "factory_girl"
require "faker"

FactoryGirl.define do
  factory :billing_address do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }

    address { Faker::Address.street_address }
    city    { Faker::Address.city }
    state   { Faker::Address.state }
    zip     { Faker::Address.zip }
    country { Faker::Address.country_code }

    user_id { build(:user).id }

    trait :invalid do
      email { "invalid" }
    end
  end
end
