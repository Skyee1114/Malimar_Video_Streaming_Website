require "delayed_active_job_broadcaster"

Wisper.configure do |config|
  config.broadcaster :async, DelayedActiveJobBroadcaster.new
end
