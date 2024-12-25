require_relative "db"
require_relative "loader/collection"

module Resource
  NotFoundError = Class.new StandardError

  class << self
    def find(id, feeds, **options)
      load_resources(feeds, **options).detect do |resource|
        id == resource.id
      end || raise(NotFoundError)
    rescue URI::InvalidURIError, Loader::LoadError
      raise NotFoundError
    end

    def all(feeds, **options)
      load_resources(feeds, **options).to_a
    rescue URI::InvalidURIError, Loader::LoadError
      raise NotFoundError
    end

    private

    def load_resources(feeds, limit: nil, **options)
      Enumerator.new do |resources|
        Array(feeds).each do |feed|
          raise NotFoundError unless feed.valid?

          remote_resources = DB.new(feed.url).resources(limit: limit)

          Loader::Collection.new(remote_resources, **options).all.each do |resource|
            resources << resource
          end
        end
      end
    end
  end
end
