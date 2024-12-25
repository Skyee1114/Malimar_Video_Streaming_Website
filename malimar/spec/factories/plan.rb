require "factory_girl"
require "faker"

FactoryGirl.define do
  factory :plan do
    name { "#{Faker::Name.first_name} plan" }
    cost { "33.00" }
    period_in_monthes 3

    includes_web_content false
    includes_roku_content false

    trait :web do
      includes_web_content true
    end

    trait :roku do
      includes_roku_content true
    end

    trait :one_month do
      name "1 Month Membership"
      period_in_monthes 1
    end
  end
end
