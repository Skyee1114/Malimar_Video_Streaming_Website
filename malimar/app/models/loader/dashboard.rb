require_relative "remote_resource"
require_relative "../resource/container"

module Loader
  class Dashboard < RemoteResource
    def valid?
      super &&
        remote_resource.has_field?("feed") &&
        "grid" == remote_resource.feed_type
    end

    def load
      Resource::Container.new(
        **defaults,
        type: :dashboard,
        title: record["title"],
        url: record["feed"],
        description: record["description"],

        cover_image: {
          sd: record["sdImg"],
          hd: record["hdImg"]
        }
      )
    end
  end
end
