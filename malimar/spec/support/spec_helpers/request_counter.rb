require "webmock"

module SpecHelpers
  module RequestCounter
    def count_requests(*args)
      request_pattern = WebMock.send(:convert_uri_method_and_options_to_request_and_options, args[0], args[1], args[2]).first
      WebMock::RequestRegistry.instance.times_executed(request_pattern)
    end
  end
end
