require "factory_girl"
require "faker"
require_relative "user"

FactoryGirl.define do
  factory :password_reset, class: User::PasswordReset do
    email

    initialize_with { new attributes }
  end
end
