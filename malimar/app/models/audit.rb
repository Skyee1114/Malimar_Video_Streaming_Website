require_relative "audit/recently_played"

module Audit
  class << self
    def recently_played(user)
      RecentlyPlayed.new(user).resources
    end
  end
end
