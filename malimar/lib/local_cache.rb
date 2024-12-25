class LocalCache
  NotFound = Class.new StandardError
  class << self
    def fetch(key, expires_in: 1.hour)
      get key
    rescue NotFound
      set key, yield, expires_in: expires_in
      get key
    end

    def get(key)
      raise NotFound if expired? key

      @cache[key]
    end

    def set(key, value, expires_in:)
      set_expiration key, expires_in
      @cache[key] = value
    end

    def clear!
      @cache = {}
      @expiration = {}
    end

    private

    def expiration_time(key)
      @expiration.fetch key, 1.year.ago
    end

    def set_expiration(key, expires_in)
      @expiration[key] = Time.now.utc + expires_in
    end

    def expired?(key)
      Time.now.utc + rand(5.minutes) > expiration_time(key)
    end
  end

  clear!
end
