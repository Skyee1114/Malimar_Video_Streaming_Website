# frozen_string_literal: true

$LOAD_PATH << File.expand_path('models', File.dirname(__FILE__))

require 'sinatra/base'
require 'sinatra/subdomain'
require 'json'
require 'url_tokenizer'
require 'url_tokenizer/limelight'
require 'url_tokenizer/cdn77'
require 'url_tokenizer/wowza'
require 'url_tokenizer/fastly'
require 'url_tokenizer/fastly_query_string'
require 'url_tokenizer/cloudflare'
require 'url_tokenizer/echo'

UrlTokenizer.register(
  limelighttoken: UrlTokenizer::Limelight.new(
    ENV['LL_TOKEN'],
    expires_in: ENV['LL_EXPIRATION']
  ),

  limelightcookie: UrlTokenizer::Limelight.new(
    ENV['LL_TOKEN'],
    expires_in: ENV['LL_EXPIRATION'].to_i,
    cf: ENV['LL_CF'].to_i,
    cd: ENV['LL_CD'].to_i
  ),

  cdn77token: UrlTokenizer::CDN77.new(
    ENV['CDN77_TOKEN'],
    expires_in: ENV['CDN77_EXPIRATION']
  ),

  wowzamstoken: UrlTokenizer::Wowza.new(
    ENV['WOWZA_TOKEN'],
    expires_in: ENV['WOWZA_EXPIRATION'],
    ignore_in_path: %r{(lb\:8086/)?lb/}
  ),

  fastlytoken: UrlTokenizer::Fastly.new(
    ENV['FASTLY_TOKEN'],
    expires_in: ENV['FASTLY_EXPIRATION']
  ),

  fastlyadstoken: UrlTokenizer::FastlyQueryString.new(
    ENV['FASTLY_TOKEN'],
    expires_in: ENV['FASTLY_EXPIRATION']
  ),

  cloudflaretoken: UrlTokenizer::Cloudflare.new(
    ENV['CLOUDFLARE_TOKEN'],
    expires_in: ENV['CLOUDFLARE_EXPIRATION']
  ),

  notoken: UrlTokenizer::Echo.new
)

class TokenServiceApp < Sinatra::Application
  register Sinatra::Subdomain

  get '/ping' do
    {
      name: self.class.name,
      requested_at: Time.now,
      status: 'ok'
    }.to_json
  end

  subdomain do
    get '/' do
      content_type :json
      content_url = params[:url]
      requested_provider = subdomain
      return no_url if content_url.nil? || content_url.empty?

      tokenizer = UrlTokenizer.provider(requested_provider)

      { url: tokenizer.call(content_url) }.to_json
    end

    private

    def no_url
      halt 404
    end
  end
end
