require "factory_girl"
require "faker"
require "models/resource/container" unless defined? Rails
require_relative "embedded"
require_relative "feed"

FactoryGirl.define do
  sequence(:container_id) { |n| "Container_#{n}" }

  factory :container, class: Resource::Container do
    id                { generate :container_id }
    url               { Faker::Internet.url }
    title             { Faker::Lorem.sentence }
    title_translated  { Faker::Lorem.sentence }
    content_type      { RestictableContent::TYPES.sample }
    description       "Updated On: 10-Mar-2015 with 23 Episode(s) Plays On: Everyday Language: Lao Language: Lao"
    container         { build :feed, id: "HomeGrid" }

    trait(:free)    { content_type "FR" }
    trait(:premium) { content_type "PR" }
    trait(:adult)   { content_type "AD" }

    factory :show do
      cover_image { build :cover_image }

      trait :animals do
        id "WonderfulAnimals19"
        url "https://malimartv.s3.amazonaws.com/roku/xml/Home/WonderfulAnimals19.xml"
        title "WONDERFUL ANIMALS"
        cover_image { build :cover_image, sd: "https://i.malimarcdn.com/WonderfulAnimals19.jpg", hd: "https://i.malimarcdn.com/WonderfulAnimals19HDF.jpg" }
        description "Updated On: 22-Jul-2019 with 42  Episode(s)  Plays On: Monday, Tuesday, Saturday, Sunday Language: Thai"
        content_type "FR"
      end

      trait :hmong do
        id "VimKojKuvThaijPaubKevHlub"
        url "https://malimartv.s3.amazonaws.com/roku/xml/Home/VimKojKuvThaijPaubKevHlub.xml"
        title "VIM KOJ KUV THAIJ PAUB KEV HLUB"
        cover_image { build :cover_image, sd: "http://malimar.vo.llnwd.net/v1/images/VimKojKuvThaijPaubKevHlub.jpg", hd: "http://malimar.vo.llnwd.net/v1/images/VimKojKuvThaijPaubKevHlubHD.jpg" }
        content_type "PR"
      end
    end

    factory :grid do
      trait :live_tv do
        id "LiveTV_Free_Premium_Sponsors_CF"
        url "https://malimartv.s3-accelerate.amazonaws.com/roku/xml/Home/LiveTV_Free_Premium_Sponsors_CF.xml"
        title "ROW 1  Live TV | Free"
      end

      trait :documentary do
        id "Documentary_and_Education_CF"
        url "https://malimartv.s3-accelerate.amazonaws.com/roku/xml/Home/Documentary_and_Education_CF.xml"
        title "Documentary and Education"
      end

      trait :english_for_free do
        id "LiveTV_Free_English_CF"
        url "https://malimartv.s3-accelerate.amazonaws.com/roku/xml/Home/LiveTV_Free_English_CF.xml"
        title "ROW 5 Live TV | Free English"
      end

      trait :premium_tv do
        id "LiveTV_Premium_CF"
        url "https://malimartv.s3-accelerate.amazonaws.com/roku/xml/Home/LiveTV_Premium_CF.xml"
        title "ROW 3  Live TV | Premium"
      end

      # dashboard: hmong
      trait :hmong_tv do
        id "HmongTV_Live_CF"
        url "https://malimartv.s3.amazonaws.com/roku/xml/Home/HmongTV_Live_CF.xml"
        title "HMONGTV LIVE"
        content_type "PR"
      end

      # dashboard: lao
      trait :lao_music do
        id "Lao_Music_CF"
        url "https://malimartv.s3.amazonaws.com/roku/xml/Home/Lao_Music_CF.xml"
        title "LAO MUSIC"
        content_type "FR"
      end

      # dashboard: lao
      trait :lao_movie do
        id "Lao_Movie_CF"
        url "https://malimartv.s3.amazonaws.com/roku/xml/Home/Lao_Movie_CF.xml"
        title "LAO MOVIE"
        content_type "FR"
      end
    end

    factory :dashboard do
      trait :lao do
        id "lao"
        url "https://malimartv.s3.amazonaws.com/roku/xml/Home/lao.xml"
        title "LAO LIVE AND ON DEMAND"
        content_type "PR"
      end

      trait :hmong do
        id "hmong"
        url "https://malimartv.s3.amazonaws.com/roku/xml/Home/hmong.xml"
        title "HMONG"
        content_type "PR"
      end
    end

    initialize_with { new attributes }
  end
end
