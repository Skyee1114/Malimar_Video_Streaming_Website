module SpecHelpers
  module Authentication
    def as(user)
      sign_in user
      yield
    ensure
      sign_out
    end

    def sign_in(user, **params)
      http_authorization_header user: user, **params
    end

    def sign_out
      remove_authorization_header
    end

    private

    def http_authorization_header(user: nil, token: nil, auth_header: nil, basic: false)
      auth_header ||= ActionController::HttpAuthentication::Basic.encode_credentials(user.email, basic) if basic

      auth_header ||= "Bearer #{token || tokenizer.generate_token(user)}"

      if respond_to? :header
        header "AUTHORIZATION", auth_header
      else
        request.env["HTTP_AUTHORIZATION"] = auth_header
      end
    end

    def remove_authorization_header
      if respond_to? :header
        example.metadata[:headers].delete "AUTHORIZATION"
      else
        request.env.delete "HTTP_AUTHORIZATION"
      end
    end

    def tokenizer
      @tokenizer ||= Tokenizer.new encoder_key: Rails.application.secrets.secret_key_base
    end
  end
end
