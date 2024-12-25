require "redis-store"
require_relative "../../models/authentication"

module Authentication
  class RecentLoginPolicyCheck
    Error = Class.new PolicyError

    def self.redis_connection
      @redis_connection ||= Redis::Store::Factory.create "redis://#{ENV['REDIS_HOST']}:6379/0/logins"
    end

    def initialize(allowed_login_count = ENV["SESSIONS_PER_USER"], redis: self.class.redis_connection)
      @redis = redis
      @allowed_login_count = allowed_login_count.to_i
    end

    def token_issued(user, payload, **_options)
      store_login user, payload.fetch(:iat).to_f
    rescue KeyError
      raise Authentication::Error.new $!, backend: ActionController::HttpAuthentication::Bearer
    end

    def user_loaded(user, payload)
      iat = payload.fetch(:iat).to_f
      last_issue = get_last_login user

      raise Error, "Someone else signed in to your account recently" if last_issue > iat
    rescue KeyError
      raise Authentication::Error.new $!, backend: ActionController::HttpAuthentication::Bearer
    end

    private

    attr_reader :allowed_login_count, :redis

    def store_login(user, iat)
      redis.lpush issue_key(user), iat
      redis.ltrim issue_key(user), 0, (allowed_login_count - 1)
    end

    def get_last_login(user)
      redis.lrange(issue_key(user), 0, (allowed_login_count - 1)).last.to_f
    end

    def issue_key(user)
      user.id.to_s
    end
  end
end
