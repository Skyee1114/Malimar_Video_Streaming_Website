module SpecHelpers
  module JsonResponse
    def json_response
      JSON.parse!(response_body, symbolize_names: true)
    end

    def response_body
      return super if defined? super

      response.body
    end
  end
end
