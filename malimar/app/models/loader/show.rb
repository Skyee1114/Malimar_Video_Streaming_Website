require_relative "remote_resource"
require_relative "../resource/container"

module Loader
  class Show < RemoteResource
    def valid?
      super &&
        remote_resource.has_field?("feed") &&
        remote_resource.feed_type == "episodes"
    end

    def load
      Resource::Container.new(
        **defaults,
        type: :show,
        title: record["title"],
        url: record["feed"],
        description: record["description"],
        recently_updated: recently_updated_record?,

        cover_image: {
          sd: record["sdImg"],
          hd: record["hdImg"]
        }
      )
    end
  end
end
