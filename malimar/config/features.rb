feature :free do
  ENV["FEATURE_ALL_CONTENT_FREE"] == "on"
end

feature :beta do
  ENV["FEATURE_BETA"] == "on"
end

feature :subscription do
  feature_active?(:registration) &&
    ENV["FEATURE_SUBSCRIPTION"] == "on"
end

feature :registration do
  ENV["FEATURE_REGISTRATION"] == "on"
end

feature :payments do
  ENV["FEATURE_PAYMENTS"] == "on"
end

feature :roku do
  ENV["FEATURE_ROKU"] == "on"
end
