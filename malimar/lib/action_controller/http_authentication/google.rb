require_relative "bearer"

module ActionController
  module HttpAuthentication
    class Google < Bearer
      def self.auth_schema
        "Google"
      end
    end
  end
end
