require "virtus"
require_relative "quality"

module Resource::Embedded
  class VideoStream
    include Virtus.value_object

    values do
      attribute :quality,   Quality
      attribute :url,       String
      attribute :provider,  String
    end
  end
end
