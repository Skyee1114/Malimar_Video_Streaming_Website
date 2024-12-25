require "factory_girl"

require_relative "card"
require_relative "billing_address"

FactoryGirl.define do
  factory :card_payment do
    amount { 12 }
    description { "1 Month Roku payment" }
    invoice { "ABC1" }
    custom_fields { { foo: :bar } }

    card { build :card }
    billing_address { build :billing_address }

    initialize_with { new attributes }
  end
end
