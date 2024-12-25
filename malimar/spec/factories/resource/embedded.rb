require "factory_girl"
require "faker"

FactoryGirl.define do
  factory :video_stream, class: Resource::Embedded::VideoStream do
    url { "#{Faker::Internet.url}/stream/playlist" }
    quality { { category: "SD", bitrate: 24 } }
    provider { "WowzaMS" }

    trait :sd do
      quality { { category: "SD", bitrate: 24 } }
    end

    trait :hd do
      quality { { category: "HD", bitrate: 3000 } }
    end

    initialize_with { new attributes }
  end

  factory :cover_image, class: Resource::Embedded::CoverImage do
    sd { Faker::Internet.url }
    hd { Faker::Internet.url }

    initialize_with { new attributes }
  end

  factory :background_image, class: Resource::Embedded::BackgroundImage do
    sd { Faker::Internet.url }
    hd { Faker::Internet.url }

    initialize_with { new attributes }
  end
end
