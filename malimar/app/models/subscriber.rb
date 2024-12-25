require "wisper"

class Subscriber
  include Wisper.publisher

  def initialize(subject)
    @subject = subject
  end

  def subscribe_to_plan(plan)
    subscription = subject.subscription
    subscription.add_time additional_time(plan)
  end

  def revoke_all
    subscription = subject.subscription
    subscription.revoke
  end

  private

  attr_reader :subject

  def additional_time(plan)
    {
      premium: plan.period_in_monthes.months
    }
  end
end
