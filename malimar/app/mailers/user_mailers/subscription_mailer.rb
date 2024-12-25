require_relative "../domain_mailer"
module UserMailers
  class SubscriptionMailer < DomainMailer
    default from: ENV["SUBSCRIPTION_EMAIL_SENDER"]

    def new_device_activation(activation)
      @activation = Device::ActivationPresenter.new activation
      mail subject: "Device activation", to: @activation.email
    end

    def new_device_subscription(device, transaction)
      @payment = PaymentPresenter.new transaction, device: device, subscription: device.subscription
      mail subject: "#{company_name} TV Network | Your #{device.name} Payment Details", to: @payment.email
    end

    def new_web_subscription(user, transaction)
      @payment = PaymentPresenter.new transaction, user: user, subscription: user.subscription
      mail subject: "#{company_name} TV Network | Your Payment Details", to: @payment.email
    end

    def subscription_expire_soon(user)
      @user = user
      mail subject: "#{company_name} TV Network | Your Subscription expires soon", to: @user.email
    end
  end
end
