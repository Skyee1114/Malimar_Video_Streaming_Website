require "active_support/core_ext/object"
require "active_support/core_ext/array"

module ActionController
  module HttpAuthentication
    class Bearer
      class << self
        def auth_schema
          "Bearer"
        end

        def has_token?(request)
          new(request).has_token?
        end

        def get_token(request)
          new(request).token
        end

        def authenticate(request)
          yield get_token(request)
        end

        def authentication_request(controller, realm)
          controller.headers["WWW-Authenticate"] = %(#{auth_schema} realm="#{realm.gsub(/"/, '')}")
          controller.response_body = "HTTP #{auth_schema}: Access denied.\n"
          controller.status = 401
        end
      end

      def initialize(request)
        @request = request
      end

      def token
        auth_param if has_token?
      end

      def has_token?
        authorization.present? && auth_schema == self.class.auth_schema
      end

      private

      attr_reader :request

      def authorization
        return request.authorization if request.respond_to? :authorization

        request.env["HTTP_AUTHORIZATION"]
      end

      def auth_schema
        authorization.split(" ", 2).first
      end

      def auth_param
        authorization.split(" ", 2).second
      end
    end
  end
end
