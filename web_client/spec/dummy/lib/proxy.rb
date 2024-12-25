# frozen_string_literal: true

require "rack/proxy"

class Proxy < Rack::Proxy
  HOSTS = {
    beta: {
      url: "www.beta-malimartv.elasticbeanstalk.com",
      ssl: false
    },

    production: {
      url: "www.malimar.tv",
      ssl: true
    }
  }.freeze

  def self.get_host(env)
    config = HOSTS[env]
    {
      url: config[:url],
      port: config[:ssl] ? 443 : 80,
      schema: config[:ssl] ? "https" : "http",
      ssl: config[:ssl]
    }
  end
  CORS_HOST = get_host(:production)

  def initialize(app)
    @app = app
  end

  def call(env)
    # call super if we want to proxy, otherwise just handle regularly via call
    (proxy?(env) && super) || @app.call(env)
  end

  def proxy?(env)
    # do not alter env here, but return true if you want to proxy for this request.
    ["application/vnd.api+json", "application/json"].any? do |type|
      env["HTTP_ACCEPT"].include? type
    end
  end

  def perform_request(env)
    return super unless env["REQUEST_METHOD"] == "GET"

    url = env["REQUEST_URI"]
    Rails.cache.read(url) || super.tap do |response|
      Rails.cache.write url, response, expires_in: 1.day if response.first == "200"
    end
  end

  def rewrite_env(env)
    if CORS_HOST[:ssl]
      env["HTTPS"] = "on"
      env["rack.ssl_verify_none"] = true
    end

    env["HTTP_HOST"] = "#{CORS_HOST[:url]}:#{CORS_HOST[:port]}"
    env
  end

  def rewrite_response(triplet)
    status, headers, body = triplet

    headers.delete "transfer-encoding"
    body.each do |part|
      part.gsub! "#{CORS_HOST[:schema]}://#{CORS_HOST[:url]}", "http://#{local_host}:3000"
    end
    triplet
  end

  private

  def local_host
    ENV["DOMAIN"]
  end
end
