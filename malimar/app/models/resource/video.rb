require "virtus"
require_relative "embedded/cover_image"
require_relative "embedded/background_image"
require_relative "embedded/video_stream"
require_relative "restrictable_content"
require_relative "feed"

module Resource
  class Video
    include Virtus.value_object
    include ActiveModel::SerializerSupport
    include RestictableContent

    values do
      attribute :id,                String
      attribute :type,              Symbol

      attribute :title,             String
      attribute :synopsis,          String
      attribute :release_date,      String
      attribute :number,            Integer

      attribute :cover_image,       Embedded::CoverImage
      attribute :background_image,  Embedded::BackgroundImage
      attribute :video_stream,      Embedded::VideoStream

      attribute :container,         Feed
      attribute :recently_updated,  Boolean, default: false
    end
  end
end
