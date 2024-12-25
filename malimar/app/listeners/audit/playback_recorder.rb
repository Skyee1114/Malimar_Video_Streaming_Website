module Audit
  class PlaybackRecorder
    def initialize(user)
      @user = user
    end

    def model_rendered(model)
      video_played model if model.is_a? Resource::Video
    end

    def video_played(video)
      return if skip? video

      add_to_recently_played video
    end

    private

    attr_reader :user

    def skip?(video)
      user.guest?
    end

    def add_to_recently_played(video)
      RecentlyPlayed.new(user).add video
    end
  end
end
