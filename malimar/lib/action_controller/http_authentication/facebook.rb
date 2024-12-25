require_relative "bearer"

module ActionController
  module HttpAuthentication
    class Facebook < Bearer
      def self.auth_schema
        "Facebook"
      end
    end
  end
end
