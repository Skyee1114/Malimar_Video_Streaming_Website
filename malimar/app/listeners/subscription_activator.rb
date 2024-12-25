require "wisper"

class SubscriptionActivator
  include Wisper.publisher

  def initialize(plan, user, device)
    @plan = plan
    @user = user
    @device = device
  end

  def successful_transaction(transaction)
    with_transaction do
      if plan.includes_web_content?
        Subscriber.new(user).subscribe_to_plan plan
        broadcast :new_web_subscription_payment, user, transaction
      end

      if plan.includes_roku_content? && device
        Subscriber.new(device).subscribe_to_plan plan
        broadcast :new_device_subscription_payment, device, transaction, wait: 10.second
      end
    end
  end

  private

  attr_reader :plan, :user, :device

  def with_transaction
    ActiveRecord::Base.transaction do
      yield
    end
  end
end
