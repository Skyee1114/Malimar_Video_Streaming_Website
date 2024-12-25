require "virtus"
require_relative "feed"
require_relative "embedded/cover_image"
require_relative "restrictable_content"

module Resource
  class Container < Feed
    include RestictableContent

    values do
      attribute :type,              Symbol
      attribute :title,             String
      attribute :title_translated,  String
      attribute :description,       String
      attribute :cover_image,       Embedded::CoverImage
      attribute :container,         Feed
      attribute :recently_updated,  Boolean, default: false
    end
  end
end
