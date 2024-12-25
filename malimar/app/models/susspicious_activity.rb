class SusspiciousActivity < ActiveRecord::Base
  ACTIONS = %i[login admin_login video_request payment subscription_cancelled].freeze
  serialize :ban_data

  belongs_to :subject, polymorphic: true

  ACTIONS.each do |action|
    scope action, -> { where(action: action) }
  end

  after_destroy :clear_bans

  class << self
    def create_from_request(req, object, user, action)
      ip = req.ip
      env = req.env

      ban_data = {
        "matched" => env["rack.attack.matched"],
        "match_discriminator" => env["rack.attack.match_discriminator"],
        "match_type" => env["rack.attack.match_type"],
        "match_period" => env.fetch("rack.attack.match_data", {}).fetch(:period, nil),
        "match_limit" => env.fetch("rack.attack.match_data", {}).fetch(:limit, 0)
      }

      activity = SusspiciousActivity.where(
        subject: user,
        action: action,
        object: object,
        ip: ip
      ).where(["created_at > ?", Date.yesterday]).first_or_initialize

      if activity.persisted?
        SusspiciousActivity.update_counters activity.id, count: 1
        activity.touch
      else
        activity.ban_data = ban_data
        activity.count = 1
        activity.save!
      end
    end
  end

  def clear_bans
    if ban_data && ban_data["match_type"] == :throttle
      Rack::Attack.reset_throttle ban_data["matched"], ban_data["match_discriminator"]
    end

    Rack::Attack::PERMANENT_BANS_STORE.srem :blacklist, ip.to_s
  end

  def banned?
    return true if Rack::Attack::PERMANENT_BANS_STORE.sismember :blacklist, ip.to_s

    if ban_data
      return if ban_data["match_type"] == :safelist

      key = "#{ban_data['matched']}:#{ban_data['match_discriminator']}"
      Rack::Attack.cache.size(key, ban_data["match_period"]) > ban_data["match_limit"].to_i
    else
      false
    end
  end
end
