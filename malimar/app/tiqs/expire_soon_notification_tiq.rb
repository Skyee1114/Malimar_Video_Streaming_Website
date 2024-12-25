require "active_support/time"

class ExpireSoonNotificatonTiq
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence backfill: false do
    weekly.day(:wednesday).hour_of_day(18)
  end

  def self.redis_connection
    @redis_connection ||= Redis::Store::Factory.create "redis://#{ENV['REDIS_HOST']}:6379/0/expire_notifications"
  end

  def initialize(period: 1.month, redis: self.class.redis_connection)
    @period = period
    @redis = redis
  end

  def perform
    User::Local.expire_soon.each do |user|
      next if email_sent? user

      send_mail user
    end
  end

  private

  attr_reader :redis, :period

  def send_mail(user)
    redis.set issue_key(user), Time.now.utc, expires_in: period
    UserMailers::SubscriptionMailer.subscription_expire_soon(user).deliver_later
  end

  def email_sent?(user)
    !!redis.get(issue_key(user))
  end

  def issue_key(user)
    user.id.to_s
  end
end
