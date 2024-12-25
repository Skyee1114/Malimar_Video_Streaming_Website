require_relative "remote_resource"
require_relative "../resource/container"

module Loader
  class Grid < RemoteResource
    def valid?
      super && remote_resource.has_field?("feed")
    end

    def load
      Resource::Container.new(
        **defaults,
        type: :grid,
        title: record["title"],
        title_translated: record["titlel"],
        url: record["feed"]
      )
    end
  end
end
