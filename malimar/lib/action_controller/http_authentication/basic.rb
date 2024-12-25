require "action_controller/metal/http_authentication"

module ActionController
  module HttpAuthentication
    module Basic
      def authentication_request(controller, realm)
        type = realm == "Application" ? "xBasic" : "Basic"
        controller.headers["WWW-Authenticate"] = %(#{type} realm="#{realm.gsub(/"/, '')}")
        controller.response_body = "HTTP Basic: Access denied.\n"
        controller.status = 401
      end

      def has_basic_credentials?(request)
        authorization(request).present? && (auth_scheme(request) == "Basic")
      end

      def auth_scheme(request)
        authorization(request).split(" ", 2).first
      end

      def auth_param(request)
        authorization(request).split(" ", 2).second
      end

      private

      def authorization(request)
        return request.authorization if request.respond_to? :authorization

        request.env["HTTP_AUTHORIZATION"]
      end
    end
  end
end
