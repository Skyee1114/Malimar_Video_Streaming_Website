if Rails.env.production?
  require "action_controller/http_authentication/basic"

  AUDIT_TAGGER = Audit::AuthenticationTag.new(encoder_key: Rails.application.secrets.secret_key_base)

  class Rack::Attack
    PER_VIDEO_REQUESTS = 24
    AUTO_BAN_OVERLIMIT_FACTOR = 10

    PER_SECOND_VIDEO_REQUESTS = 2
    PER_SECOND_VIDEO_REQUESTS_DAYLY_ALLOWANCE = 80
    PER_SECOND_VIDEO_REQUESTS_PERION_IN_DAYS = 3

    throttle("logins/ip", limit: 10, period: 10.minutes) do |req|
      req.ip if req.path.starts_with?("/sessions") && req.post?
    end

    # Invitations
    throttle("invitations/ip", limit: 5, period: 10.minutes) do |req|
      req.ip if req.path.starts_with?("/invitations") && req.post?
    end

    # Password resets
    throttle("passwords/ip", limit: 5, period: 10.minutes) do |req|
      req.ip if req.path.starts_with?("/passwords") && req.post?
    end

    # Subscriptions
    throttle("subscription_update/ip", limit: 15, period: 10.minute) do |req|
      req.ip if req.path.starts_with?("/subscriptions") && req.put?
    end

    # Payments
    throttle("payments/ip", limit: 5, period: 5.minutes) do |req|
      req.ip if req.path.starts_with?("/subscription_payments") && req.post?
    end

    # Ban video leechers
    throttle("video_leechs/ip", limit: PER_VIDEO_REQUESTS, period: 1.day) do |req|
      if (req.path.to_s.include?("json") || req.env["HTTP_ACCEPT"].to_s.include?("json")) \
          &&
         (req.path =~ %r{channels/([^\\]+)} || req.path =~ %r{episodes/([^\\]+)})

        login = AUDIT_TAGGER.call(req)
        next if AUDIT_TAGGER.employee_login?(login)

        id = Regexp.last_match(1).sub ".json", ""
        "#{id}:#{req.ip}"
      end
    end

    safelist("video_leechs/login") do |req|
      login = AUDIT_TAGGER.call(req)

      Rack::Attack::Allow2Ban.filter(login, maxretry: PER_SECOND_VIDEO_REQUESTS_DAYLY_ALLOWANCE * PER_SECOND_VIDEO_REQUESTS_PERION_IN_DAYS, findtime: PER_SECOND_VIDEO_REQUESTS_PERION_IN_DAYS.days, bantime: 10.seconds) do
        Rack::Attack::Allow2Ban.filter("try_#{login}", maxretry: PER_SECOND_VIDEO_REQUESTS, findtime: 1.seconds, bantime: 5.seconds) do
          if (req.path.to_s.include?("json") || req.env["HTTP_ACCEPT"].to_s.include?("json")) \
              &&
             (req.path =~ %r{channels/([^\\]+)} || req.path =~ %r{episodes/([^\\]+)})

            AUDIT_TAGGER.known_login?(login) && !AUDIT_TAGGER.employee_login?(login)
          end
        end
      end
    end

    track("admin/basic", limit: 10, period: 30.minutes) do |req|
      if req.path.starts_with? "/admin"
        auth_strategy = Authentication::LoginStrategy.new(req)
        next nil unless auth_strategy.valid?

        begin
          auth_strategy.authenticate
          nil
        rescue StandardError
          req.ip
        end
      end
    end

    blocklist("ip_auto_blocklist") do |req|
      PERMANENT_BANS_STORE.sismember :blocklist, req.ip
    end

    # blocklist('admin/basic') do |req|
    #   # WARNING: change findtime in SusspiciousActivity as well
    #   Allow2Ban.filter(req.ip, maxretry: 10, findtime: 30.minutes, bantime: 2.hours) do
    #     next false unless req.path.starts_with? '/admin'

    #     auth_strategy = Authentication::LoginStrategy.new(req)
    #     next false unless auth_strategy.valid?

    #     ! auth_strategy.authenticate rescue true
    #   end
    # end

    # blocklist('sidekiq/basic') do |req|
    #   Allow2Ban.filter(req.ip, maxretry: 30, findtime: 1.minute, bantime: 2.hours) do
    #     next false unless req.path.starts_with? '/sidekiq'

    #     auth = Rack::Auth::Basic::Request.new(req.env)
    #     next false unless auth.provided?

    #     auth.credentials != [ENV['SIDEKIQ_ADMIN'], ENV['SIDEKIQ_PASSWORD']]
    #   end
    # end

    blocklist("ali.txt") do |req|
      req.path.include? "ali.txt"
    end

    ### Configure Cache ###

    # If you don't want to use Rails.cache (Rack::Attack's default), then
    # configure it here.
    #
    # Note: The store is only used for throttling (not blacklisting and
    # whitelisting). It must implement .increment and .write like
    # ActiveSupport::Cache::Store

    Rack::Attack.cache.store = Redis::Store::Factory.create "redis://#{ENV['REDIS_HOST']}:6379/1/attack"
    PERMANENT_BANS_STORE = Redis::Store::Factory.create "redis://#{ENV['REDIS_HOST']}:6379/1/bans"

    ### Throttle Spammy Clients ###

    # If any single client IP is making tons of requests, then they're
    # probably malicious or a poorly-configured scraper. Either way, they
    # don't deserve to hog all of the app server's CPU. Cut them off!
    #
    # Note: If you're serving assets through rack, those requests may be
    # counted by rack-attack and this throttle may be activated too
    # quickly. If so, enable the condition to exclude them from tracking.

    # Throttle all requests by IP (100rpm)
    #
    # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
    # throttle('req/ip', limit: 500, period: 5.minute) do |req|
    #   req.ip unless req.path.starts_with?('/assets')
    # end

    ### Prevent Brute-Force Login Attacks ###

    # The most common brute-force login attack is a brute-force password
    # attack where an attacker simply tries a large number of emails and
    # passwords to see if any credentials match.
    #
    # Another common method of attack is to use a swarm of computers with
    # different IPs to try brute-forcing a password for a specific account.

    # Throttle POST requests to /login by IP address
    #
    # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
    # Throttle POST requests to /login by email param
    #
    # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{req.email}"
    #
    # Note: This creates a problem where a malicious user could intentionally
    # throttle logins for another user and force their login requests to be
    # denied, but that's not very common and shouldn't happen to you. (Knock
    # on wood!)
    # throttle("logins/email", :limit => 5, :period => 20.seconds) do |req|
    #   if req.path == '/sessions' && req.post?
    #     # return the email if present, nil otherwise
    #     req.params['sessions'].try['email'].presence
    #   end
    # end

    ### Custom Throttle Response ###

    # By default, Rack::Attack returns an HTTP 429 for throttled responses,
    # which is just fine.
    #
    # If you want to return 503 so that the attacker might be fooled into
    # believing that they've successfully broken your app (or you just want to
    # customize the response), then uncomment these lines.
    self.throttled_response = lambda do |env|
      retry_after = (env["rack.attack.match_data"] || {})[:period]
      blocked = [429, { "Content-Type" => "text/plain", "Retry-After" => retry_after.to_s }, ["Retry later\n"]]

      json_not_found = [404, {
        "Cache-Control" => "no-cache",
        "Content-Type" => "application/json",
        "X-Content-Type-Options" => "nosniff",
        "X-Frame-Options" => "SAMEORIGIN",
        "X-XSS-Protection" => "1; mode=block"
      }, []]

      case env["rack.attack.matched"]
      when "video_leechs/ip", "video_leechs/login"
        json_not_found
      else
        blocked
      end
    end

    self.blocklisted_response = lambda do |_env|
      raise ActionController::RoutingError, "Not Found"
    end

    def self.reset_throttle(name, discriminator)
      throttle = @throttles[name]
      throttle&.reset(discriminator)
    end

    class Throttle
      def reset(discriminator)
        current_period = period.respond_to?(:call) ? period.call(req) : period
        cache.reset_count "#{name}:#{discriminator}", current_period
      end
    end

    class Cache
      def size(unprefixed_key, period)
        return 0 if period.to_i.zero?

        key, = key_and_expiry(unprefixed_key, period)
        store.read(key).to_i
      end
    end
  end

  ActiveSupport::Notifications.subscribe("rack.attack") do |_name, _start, _finish, _request_id, req|
    object = nil
    user   = nil
    data = req.env.fetch("rack.attack.match_data", {})
    count = data.fetch :count, 0
    limit = data.fetch :limit, 1

    case req.env["rack.attack.matched"]
    when "logins/ip"
      action = :login
      if ActionController::HttpAuthentication::Basic.has_basic_credentials? req
        auth = Rack::Auth::Basic::Request.new(req.env)
        object = auth.credentials.try(:first)
        user = User::Local.where(login: object).take
      end

    when "video_leechs/ip"
      action = :video_request
      object = req.path
      auth_strategy = Authentication::TokenStrategy.new(req, encoder_key: Rails.application.secrets.secret_key_base)
      user = begin
               auth_strategy.authenticate
             rescue StandardError
               nil
             end

    when "payments/ip"
      action = :payment

      post_data = begin
                    Oj.safe_load(req.env["RAW_POST_DATA"])
                  rescue StandardError
                    {}
                  end
      post_data.default = {}
      plan_id = post_data["subscription_payments"]["links"]["plan"]
      object = Plan.where(id: plan_id).take.try(:name)

      auth_strategy = Authentication::TokenStrategy.new(req, encoder_key: Rails.application.secrets.secret_key_base)
      user = begin
               auth_strategy.authenticate
             rescue StandardError
               nil
             end

    when "admin/basic"
      action = :admin_login
      if ActionController::HttpAuthentication::Basic.has_basic_credentials? req
        auth = Rack::Auth::Basic::Request.new(req.env)
        object = auth.credentials.try(:first)
        user = User::Local.where(login: object).take
      end

    when "video_leechs/login"
      action = :subscription_cancelled

      if ActionController::HttpAuthentication::Basic.has_basic_credentials? req
        auth = Rack::Auth::Basic::Request.new(req.env)
        object = auth.credentials.try(:first)
      else
        object = AUDIT_TAGGER.call(req)
      end
      user = User::Local.where(login: object).take

      if user
        activity = SusspiciousActivity.create_from_request req, object, user, action

        old_expiration = user.subscription.expiration_of(:premium)
        Subscriber.new(user).revoke_all

        if old_expiration > Time.now.utc
          CompanyMailers::SubscriptionMailer.subscription_revoked(user, activity: activity, old_expiration: old_expiration.to_s).deliver_later
        end
      end

    else next
    end

    if count > limit * Rack::Attack::AUTO_BAN_OVERLIMIT_FACTOR
      Rack::Attack::PERMANENT_BANS_STORE.sadd :blocklist, req.ip
    end

    SusspiciousActivity.create_from_request req, object, user, action
  end
end
