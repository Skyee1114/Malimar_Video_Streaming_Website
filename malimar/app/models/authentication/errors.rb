module Authentication
  PolicyError = Class.new StandardError

  class Error < StandardError
    def initialize(message, backend:, realm: "Application")
      super message
      @backend = backend
      @realm = realm
    end
    attr_reader :backend, :realm
  end
end
