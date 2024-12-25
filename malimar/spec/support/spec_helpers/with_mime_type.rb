module SpecHelpers
  module WithMimeType
    def with_mime_type(type)
      Rack::MockRequest::DEFAULT_ENV["HTTP_ACCEPT"] = type
      yield
      Rack::MockRequest::DEFAULT_ENV.delete "HTTP_ACCEPT"
    end
  end
end
