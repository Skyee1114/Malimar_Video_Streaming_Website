require "factory_girl"
require "faker"

FactoryGirl.define do
  factory :rewrite_rule do
    from { Faker::Lorem.word }
    to { Faker::Lorem.word }
    subject :url

    trait :url do
      subject :url
    end

    trait :image do
      subject :image
    end
  end
end
