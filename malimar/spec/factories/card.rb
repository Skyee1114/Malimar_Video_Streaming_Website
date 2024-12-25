require "factory_girl"
require "faker"

FactoryGirl.define do
  factory :card do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    cvv { 123 }
    number { "4111-1111-1111-1111" }
    expiry_month { Faker::Number.between(1, 12) }
    expiry_year do
      year = Time.now.year
      Faker::Number.between(year + 1, year + 10)
    end

    initialize_with { new attributes }

    trait :invalid do
      number { "" }
    end
  end
end
