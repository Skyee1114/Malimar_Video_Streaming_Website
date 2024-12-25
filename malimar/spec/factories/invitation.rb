require "factory_girl"
require "faker"
require_relative "user"

FactoryGirl.define do
  factory :invitation, class: User::Invitation do
    email

    initialize_with { new attributes }
  end
end
