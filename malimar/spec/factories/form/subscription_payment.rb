require "factory_girl"
require "faker"
require_relative "../plan"
require_relative "../user"

require_relative "../billing_address"
require_relative "../card"

FactoryGirl.define do
  factory :subscription_payment_form, class: Form::SubscriptionPayment do
    plan { create :plan, :web }
    user { create :user, :premium }

    billing_address { build(:billing_address).attributes.except("id", "user_id") }
    card { build(:card).to_h }

    initialize_with { new attributes }
  end
end
