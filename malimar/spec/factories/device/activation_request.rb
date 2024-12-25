require "factory_girl"
require "faker"
require_relative "roku"

FactoryGirl.define do
  factory :device_activation_request, class: Device::ActivationRequest do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }

    address { Faker::Address.street_address }
    city    { Faker::Address.city }
    state   { Faker::Address.state }
    zip     { Faker::Address.zip }
    country { "CA" }

    device   { build :roku_device }
    referral { "friend" }
    service  { "trial" }

    initialize_with { new attributes }
  end
end
