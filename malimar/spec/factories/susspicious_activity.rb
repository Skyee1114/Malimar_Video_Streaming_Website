require "factory_girl"
require "faker"

FactoryGirl.define do
  factory :susspicious_activity do
    action "login"
    object { Faker::Internet.email }
  end
end
