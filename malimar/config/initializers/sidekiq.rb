if Rails.env.production? || Rails.env.migration?
  require "sidekiq"
  require "sidekiq/web"
  require "sidetiq/web"

  Sidekiq.configure_server do |config|
    config.redis = { url: "redis://#{ENV['REDIS_HOST']}:6379/1" }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: "redis://#{ENV['REDIS_HOST']}:6379/1" }
  end

  Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
    [user, password] == [ENV["SIDEKIQ_ADMIN"], ENV["SIDEKIQ_PASSWORD"]]
  end

  middlewares = Sidekiq::Web.instance_variable_get(:@middleware)

  middlewares.delete_if do |middleware|
    middleware.first == Rack::Protection
  end
end
