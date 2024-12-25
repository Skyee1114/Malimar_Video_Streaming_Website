module ActionCacheable
  extend ActiveSupport::Concern

  class_methods do
    def action_cache_options
      {
        expires_in: ENV["CACHE_RESPONSE_FOR"],
        race_condition_ttl: 20
      }
    end
  end

  # HACK: for the pundit
  def read_fragment(*args)
    super.tap do |fragment|
      if fragment
        skip_policy_scope
        skip_authorization
      end
    end
  end
end
