require_relative "../serializer"

module Callback
  class RokupayNotificationSerializer < Serializer
    self.root = "rokupay_notifications"
    attributes :plan

    def plan
      @plan ||= object.plan.name
    end
  end
end
