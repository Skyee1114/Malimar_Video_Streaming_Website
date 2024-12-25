class PlayerSelector
  NoPlayerAvailableError = Class.new(StandardError)

  def initialize(viewer, player_urls = nil)
    @viewer = viewer
    @player_urls = player_urls
  end

  def url
    content_type = :premium if viewer.subscription.has_access_to?(:premium)
    content_type ||= :free

    player_url = player_urls[content_type].presence
    return player_url if player_url

    player_urls[:free].presence || raise(NoPlayerAvailableError)
  end

  private

  attr_reader :viewer

  def player_urls
    @player_urls ||= build_player_urls
  end

  def build_player_urls
    {
      free: "//cdn.jwplayer.com/libraries/iMxCLH6i.js",
      premium: "//cdn.jwplayer.com/libraries/iMxCLH6i.js"
    }
  end
end
