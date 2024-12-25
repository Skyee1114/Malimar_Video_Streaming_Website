require_relative "../serializer"

class Resource::ChannelSerializer < Serializer
  self.root = "channels"
  attributes :id, :title, :synopsis, :cover_image, :stream_url, :background_image

  has_one :container

  def stream_url
    @stream_url ||= PlayableUrl.new(object.video_stream, ip: options[:ip]).url
  end

  # NOT used
  def player_url
    @player_url ||= PlayerSelector.new(scope).url
  end
end
