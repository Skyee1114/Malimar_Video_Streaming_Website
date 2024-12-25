require_relative "episode_serializer"

class Resource::PlayableEpisodeSerializer < Resource::EpisodeSerializer
  attributes :stream_url, :player_url, :background_image

  def stream_url
    @stream_url ||= PlayableUrl.new(object.video_stream, ip: options[:ip]).url
  end

  def player_url
    @player_url ||= PlayerSelector.new(scope).url
  end
end
