require "url_tokenizer"

class PlayableUrl
  def self.playable?(url)
    %w[?token= wowzatokenhash= &h= ?secure=].any? do |token_key|
      url.to_s.include? token_key
    end
  end

  def initialize(video_stream, stream_server: nil, ip: nil)
    @video_stream = video_stream
    @stream_server = stream_server
    @ip = ip
  end

  def url
    tokenize change_server apply_rewrite_rules(video_stream.url)
  end

  private

  attr_reader :video_stream, :stream_server

  def stream_server
    @stream_server ||= ENV["STREAM_SERVER"]
  end

  def tokenize(url)
    provider = UrlTokenizer.provider choose_provider
    provider.call(url, ip: ip)
  end

  def choose_provider
    video_stream.provider
  end

  def change_server(url)
    return url if choose_provider == "LL"

    uri = URI(url)
    return url unless uri.host.include? "liveplay.malimarserver.com"

    stream_server_uri = URI(stream_server)
    uri.host = stream_server_uri.host
    uri.scheme = stream_server_uri.scheme

    uri.to_s
  end

  def apply_rewrite_rules(url)
    RewriteRule.apply(url, subject: :url)
  end

  def ip
    return if Rails.env.development?

    @ip
  end
end
