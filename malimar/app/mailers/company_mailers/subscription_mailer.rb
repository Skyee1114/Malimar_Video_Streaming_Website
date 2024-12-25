require_relative "../domain_mailer"
module CompanyMailers
  class SubscriptionMailer < DomainMailer
    layout false
    default(
      to: ENV["ROKU_ACTIVATION_EMAIL_RECEIVER"],
      from: ENV["SUBSCRIPTION_EMAIL_SENDER"]
    )

    def new_device_activation(activation)
      @activation = activation

      attachments[@activation.serial_number] = ""

      @activation = Device::ActivationPresenter.new @activation
      mail subject: "Device activation"
    end

    def new_device_subscription(device, transaction)
      attachments[device.serial_number] = ""

      @payment = PaymentPresenter.new transaction, device: device, subscription: device.subscription
      mail subject: "#{device.name} payment"
    end

    def paypal_payment_error(exception_name, raw_post_data)
      @exception_name = exception_name
      @raw_post_data = raw_post_data
      mail subject: "PayPal payment ERROR"
    end

    def rokupay_payment_error(exception_name, raw_post_data)
      @exception_name = exception_name
      @raw_post_data = raw_post_data
      mail subject: "Rokupay payment ERROR"
    end

    def subscription_revoked(user, activity:, old_expiration:)
      @susspicious_user = SusspiciousActivityPresenter.new(activity, user, old_expiration: old_expiration)
      mail subject: "Subscription revoked: #{@susspicious_user.login}", cc: TECH_EMAIL
    end
  end
end
