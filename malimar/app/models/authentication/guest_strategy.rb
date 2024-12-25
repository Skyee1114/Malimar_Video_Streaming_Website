require_relative "../authentication"

module Authentication
  class GuestStrategy
    def initialize(request)
      @request = request
    end

    def valid?
      true
    end

    def authenticate
      User::Guest.new
    end

    private

    attr_reader :request
  end
end
