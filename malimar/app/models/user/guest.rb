require "virtus"
require_relative "mimic"

module User
  class Guest < Mimic
    attribute :id,     String,  default: "guest"
    attribute :login,  String,  default: "guest"
    attribute :email,  String,  default: "guest@example.com"

    def subscription
      Subscription::Free.new self
    end
  end
end
