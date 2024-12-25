class Redis
  class Store < self
    module Namespace
      %i[lpush ltrim lrem lrange sadd sismember srem smembers].each do |method_name|
        define_method method_name do |key, *rest|
          namespace(key) { |key| super(key, *rest) }
        end
      end
    end
  end
end
