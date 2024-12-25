require "rspec/retry"

RSpec.configure do |config|
  config.verbose_retry = true
  config.default_retry_count = 1
  # config.default_sleep_interval = 1
end
