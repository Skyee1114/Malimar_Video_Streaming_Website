require "factory_girl"
require "faker"
require_relative "billing_address"

FactoryGirl.define do
  factory :transaction do
    amount 12
    description "1 month Roku"
    successful true
    transaction_id "1234567890"
    authorization_code "abc_12345"

    card "XXXX-1111"
    invoice "Test 1"

    user { build :user }
    billing_address { build :billing_address, user: user }

    trait :successful do
      successful true
    end

    trait :failed do
      successful false
    end
  end
end
