require "factory_girl"
require "faker"
require "models/resource/video" unless defined? Rails
require_relative "embedded"
require_relative "container"

FactoryGirl.define do
  sequence(:video_id) { |n| "Video_#{n}" }

  factory :video, class: Resource::Video do
    id               { generate :video_id }
    title            { Faker::Lorem.sentence }
    synopsis         { Faker::Lorem.paragraph }
    release_date     { Faker::Date.backward(days: 360) }
    cover_image      { build :cover_image }
    background_image { build :background_image }
    video_stream     { build :video_stream }
    container        { build :container }

    factory :episode do
      type :episode
      number { rand 1..100 }

      trait :animals_21 do
        id "EP1405321"
        title "Wonderful Animals | Episode 21  | Jun 08, 2019"
        synopsis ""
        release_date { Date.parse "08-Jun-2019" }
        number 21
        cover_image { build :cover_image, sd: "https://i.malimarcdn.com/WonderfulAnimals19.jpg", hd: "https://i.malimarcdn.com/WonderfulAnimals19HDF.jpg" }
        video_stream { build :video_stream, :sd, url: "https://vodhls.malimarcdn.net/1564404732_token/Documentary/WonderfulAnimals19/WonderfulAnimals19-21.m3u8" }
        content_type "FR"
      end

      trait :animals_20 do
        id "EP1405320"
        title "Wonderful Animals | Episode 20  | Jun 08, 2019"
        synopsis ""
        release_date { Date.parse "07-Jun-2019" }
        number 20
        cover_image { build :cover_image, sd: "https://i.malimarcdn.com/WonderfulAnimals19.jpg", hd: "https://i.malimarcdn.com/WonderfulAnimals19HDF.jpg" }
        video_stream { build :video_stream, :sd, url: "https://vodhls.malimarcdn.net/1564404732_token/Documentary/WonderfulAnimals19/WonderfulAnimals19-20.m3u8" }
        content_type "FR"
      end

      trait :hmong_2 do
        id "EP104502"
        title "Vim Koj Kuv Thaij Paub Kev Hlub | Episode 2 | Aug 27, 2017"
        release_date { Date.parse "27-Aug-2017" }
        number 2
        cover_image { build :cover_image, sd: "http://malimar.vo.llnwd.net/v1/images/VimKojKuvThaijPaubKevHlub.jpg", hd: "http://malimar.vo.llnwd.net/v1/images/VimKojKuvThaijPaubKevHlubHD.jpg" }
        video_stream { build :video_stream, :sd, url: "https://vodhls.malimarcdn.net/1564403857_token/Hmong/HmongDrama/VimKojKuvThaijPaubKevHlub/VimKojKuvThaijPaubKevHlub-2.m3u8" }
        content_type "PR"
      end
    end

    factory :channel do
      type :channel

      trait :tea_tv do
        id "tea_tv"
        title "TEA TV"
        video_stream { build :video_stream, :sd, url: "https://livefta.malimarcdn.com/ftaedge00/teatv.sdp/playlist.m3u8" }
      end

      trait :liveplay do
        video_stream { build :video_stream, :sd, url: "http://liveplay.malimarserver.com/ftaedge00/teatv.sdp/playlist.m3u8" }
      end

      trait :thai5 do
        id "thai_5_hd"
        title "THAI 5 HD"
        synopsis "24 Hours Live Thai Channel"
        video_stream { build :video_stream, :sd, url: "https://livehd.us.malimarcdn.com/hdliveedge00/thai5hd.stream/playlist.m3u8" }
      end
    end

    trait :recently_played do
      after(:build) do |video, evaluator|
        Audit::RecentlyPlayed.new(evaluator.user).add video
      end
    end

    trait :favorite_by do
      after(:build) do |video, evaluator|
        FavoriteVideoList.new(evaluator.user).add video
      end
    end

    trait(:free)    { content_type "FR" }
    trait(:premium) { content_type "PR" }
    trait(:adult)   { content_type "AD" }

    initialize_with { new attributes }
  end
end
