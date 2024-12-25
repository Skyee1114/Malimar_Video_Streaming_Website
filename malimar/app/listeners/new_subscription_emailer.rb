class NewSubscriptionEmailer
  class << self
    def new_device_activation(activation)
      company_mailer.new_device_activation(activation).deliver_now
      user_mailer.new_device_activation(activation).deliver_now
    end

    def new_device_subscription_payment(device, transaction)
      company_mailer.new_device_subscription(device, transaction).deliver_now
      user_mailer.new_device_subscription(device, transaction).deliver_now
    end

    def new_web_subscription_payment(user, transaction)
      user_mailer.new_web_subscription(user, transaction).deliver_now
    end

    def paypal_payment_error(exception_name, raw_post_data)
      company_mailer.paypal_payment_error(exception_name, raw_post_data).deliver_now
    end

    def rokupay_payment_error(exception_name, raw_post_data)
      company_mailer.rokupay_payment_error(exception_name, raw_post_data).deliver_now
    end

    private

    def company_mailer
      CompanyMailers::SubscriptionMailer
    end

    def user_mailer
      UserMailers::SubscriptionMailer
    end
  end
end
