require "active_support/cache/mem_cache_store"
module ActiveSupport
  module Cache
    class MemCacheStore < Store
      def increment(name, amount = 1, options = nil) # :nodoc:
        options = merged_options(options)
        instrument(:increment, name, amount: amount) do
          @data.incr(escape_key(namespaced_key(name, options)), amount, nil, 1)
        end
      rescue Dalli::DalliError => e
        logger&.error("DalliError (#{e}): #{e.message}")
        nil
      end
    end
  end
end

Rails.application.config.middleware.delete(Rack::Runtime)
