require_relative "../loader"
require_relative "channel"
require_relative "episode"
require_relative "grid"
require_relative "dashboard"
require_relative "show"

module Loader
  class Collection
    def initialize(remote_resources, loaders: nil)
      @remote_resources = remote_resources
      @loaders = loaders
    end

    def all
      Enumerator::Lazy.new(remote_resources) do |resources, remote_resource|
        loader = choose_resource_loader remote_resource
        resources << loader.load if loader
      end
    end

    private

    attr_reader :remote_resources

    def choose_resource_loader(remote_resource)
      Array(loaders).lazy.map do |loader|
        loader.new remote_resource
      end.detect(&:valid?)
    end

    def loaders
      @loaders ||= [
        Loader::Channel,
        Loader::Episode,
        Loader::Dashboard,
        Loader::Show,
        Loader::Grid
      ]
    end
  end
end
