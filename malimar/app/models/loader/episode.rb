require_relative "remote_resource"
require_relative "../resource/video"

module Loader
  class Episode < RemoteResource
    def valid?
      super && remote_resource.has_field?("episodeNumber")
    end

    def load
      media = record.fetch "media"
      Resource::Video.new(
        **defaults,
        type: :episode,

        id: record["id"],
        title: record["title"],
        number: record["episodeNumber"],
        synopsis: record["synopsis"],
        release_date: record["releaseDate"],

        cover_image: {
          sd: record["sdImg"],
          hd: record["hdImg"]
        },

        background_image: {
          sd: record["PlayerBG"],
          hd: record["PlayerBG"]
        },

        video_stream: {
          url: stream_url(media),
          quality: {
            category: media["streamQuality"],
            bitrate: media["streamBitrate"]
          },
          provider: provider_name(record)
        }
      )
    end
  end
end
