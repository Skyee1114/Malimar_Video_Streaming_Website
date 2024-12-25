require_relative "../serializer"

module Form
  class SubscriptionPaymentSerializer < Serializer
    self.root = "subscription_payments"
    attributes :amount

    has_one :plan, serializer: PlanSerializer

    def amount
      @amount ||= object.plan.cost
    end
  end
end
