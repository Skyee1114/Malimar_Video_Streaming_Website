require 'json'

module SpecHelpers
  module JsonResponse
    def json_response
      JSON.parse!(response_body, symbolize_names: true)
    end

    def response_body
      last_response.body
    end
  end
end
