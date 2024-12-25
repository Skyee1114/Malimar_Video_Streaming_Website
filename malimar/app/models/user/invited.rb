require_relative "mimic"

module User
  class Invited < Mimic
    def subscription
      Subscription::Free.new self
    end
  end
end
