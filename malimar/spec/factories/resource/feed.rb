require "factory_girl"
require "faker"
require "models/resource/feed" unless defined? Rails

FactoryGirl.define do
  sequence(:feed_id) { |n| "Feed_#{n}" }

  factory :feed, class: Resource::Feed do
    id  { generate :feed_id }
    url { Faker::Internet.url }

    initialize_with { new attributes }
  end
end
