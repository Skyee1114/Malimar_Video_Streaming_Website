require "url_tokenizer"
require "url_tokenizer/limelight"
require "url_tokenizer/cdn77"
require "url_tokenizer/fastly"
require "url_tokenizer/fastly_query_string"
require "url_tokenizer/wowza"
require "url_tokenizer/wowza_old"
require "url_tokenizer/cloudflare"
require "url_tokenizer/echo"

UrlTokenizer.register(
  LL: UrlTokenizer::Limelight.new(
    ENV["LL_TOKEN"],
    expires_in: ENV["LL_EXPIRATION"].to_i,
    cf: ENV["LL_CF"].to_i,
    cd: ENV["LL_CD"].to_i
  ),

  LL_VOD: UrlTokenizer::Limelight.new(
    ENV["LL_TOKEN"],
    expires_in: ENV["LL_EXPIRATION"].to_i,
    ip: false
  ),

  LL_C: UrlTokenizer::Limelight.new(
    ENV["LL_TOKEN"],
    expires_in: ENV["LL_EXPIRATION"].to_i,
    cf: ENV["LL_CF"].to_i,
    cd: ENV["LL_CD"].to_i
  ),

  LL_U: UrlTokenizer::Limelight.new(
    ENV["LL_TOKEN"],
    expires_in: ENV["LL_EXPIRATION"].to_i
  ),

  CDN77: UrlTokenizer::CDN77.new(
    ENV["CDN77_TOKEN"],
    expires_in: ENV["CDN77_EXPIRATION"].to_i
  ),

  WowzaMS: UrlTokenizer::Wowza.new(
    ENV["WOWZA_TOKEN"],
    expires_in: ENV["WOWZA_EXPIRATION"].to_i,
    ignore_in_path: %r{\A(lb\:8086/)?lb/},
    ip: false
  ),

  Wowza: UrlTokenizer::WowzaOld.new(
    ENV["WOWZA_OLD_TOKEN"],
    expires_in: ENV["WOWZA_OLD_EXPIRATION"].to_i
  ),

  Fastly: UrlTokenizer::Fastly.new(
    ENV["FASTLY_TOKEN"],
    expires_in: ENV["FASTLY_EXPIRATION"].to_i
  ),

  FastlyAds: UrlTokenizer::FastlyQueryString.new(
    ENV["FASTLY_TOKEN"],
    expires_in: ENV["FASTLY_EXPIRATION"].to_i
  ),

  Cloudflare: UrlTokenizer::Cloudflare.new(
    ENV["CLOUDFLARE_TOKEN"],
    expires_in: ENV["CLOUDFLARE_EXPIRATION"]
  ),

  None: UrlTokenizer::Echo.new
)
