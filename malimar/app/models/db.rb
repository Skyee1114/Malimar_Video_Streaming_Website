require "faraday"
require "nokogiri"
require "active_support/core_ext/object"

require_relative "remote_resource"

class DB
  def initialize(url, connection: nil)
    @url = url
    @connection = connection
  end

  def resources(limit: nil)
    item_documents(limit: limit).map do |item_document|
      RemoteResource.new item_document, document: document, source: url
    end
  end

  private

  attr_reader :url

  def item_documents(limit: nil)
    return document.css("item") if limit.blank?

    document.css("item").first limit.to_i
  end

  def document
    @document ||= load_document
  end

  def load_document
    Nokogiri::XML load_data
  end

  def load_data
    with_cache do
      connection.get(url).body
    end
  end

  def connection
    @connection ||=
      Faraday.new do |builder|
        builder.request :url_encoded
        builder.request :retry, max: 4, interval: 0.5,
                                interval_randomness: 0.5, backoff_factor: 2,
                                exceptions: Faraday::Adapter::NetHttp::NET_HTTP_EXCEPTIONS
        builder.adapter Faraday.default_adapter
      end
  end

  def with_cache
    return yield if Rails.env.production?

    Rails.cache.fetch url, expires_in: cache_time do
      yield
    end
  end

  def cache_time
    (ENV["CACHE_RESPONSE_FOR"] || 1.hour).to_i
  end
end
