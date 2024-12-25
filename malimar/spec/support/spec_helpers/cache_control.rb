module SpecHelpers
  module CacheControl
    STORE = ActiveSupport::Cache::FileStore.new "#{Rails.root}/tmp/cache"
    MEMORY_STORE = ActiveSupport::Cache::MemoryStore.new

    def enable_cache(clear: true, store: STORE)
      before { allow(Rails).to receive(:cache).and_return store }
      before(:context) { store.clear if clear }
    end
  end
end
