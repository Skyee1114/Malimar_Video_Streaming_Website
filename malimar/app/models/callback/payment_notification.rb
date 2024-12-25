require "wisper"

module Callback
  class PaymentNotification
    include Wisper.publisher
    Error = Class.new StandardError

    InvalidPlanError = Class.new Error
    InvalidAmountError = Class.new Error
    InvalidDeviceError = Class.new Error
    UnknownUserError = Class.new Error
    RefundError = Class.new Error

    def initialize(request)
      @request = request
    end

    def save
      transaction = create_transaction
      return false unless valid?

      activate_subscription
      broadcast :successful_transaction, transaction
    rescue Error, KeyError
      broadcast :paypal_payment_error, $!.class.name, $!.message
      false
    end

    def valid?
      return false unless feature_active? :payments

      require "paypal-sdk-core"
      # PayPal::SDK::Core::API::IPN.valid?(request.raw_post) &&
      validate_plan && validate_user && validate_device || raise(Error, request.raw_post)
    rescue RefundError
      false
    rescue Error, KeyError
      broadcast :paypal_payment_error, $!.class.name, $!.message
      false
    end

    private

    attr_reader :request
    def activate_subscription
      subscribe SubscriptionActivator.new(plan, user, device)
    end

    def create_transaction
      Transaction.create_from_paypal(
        user: user,
        fields: params
      )
    end

    def device
      @device ||=
        begin
          serial_number = params.fetch(:option_selection1, nil)
          type = params.fetch(:option_selection3, nil)
          return if [nil, "", "N/A"].include? serial_number

          if type.present?
            Device.where(serial_number: serial_number, type: type).take \
              || Device.where(serial_number: serial_number).take \
              || Device.create(serial_number: serial_number, user: user, type: type)
          else
            Device.where(serial_number: serial_number).take \
              || Device.create(serial_number: serial_number, user: user)
          end
        end
    end

    def validate_plan
      raise InvalidPlanError,    request.raw_post unless plan
      raise RefundError,         request.raw_post if amount_paid == "-#{plan.cost}"
      raise InvalidAmountError,  request.raw_post unless amount_paid == plan.cost

      true
    end

    def validate_user
      raise UnknownUserError, request.raw_post unless user

      true
    end

    def validate_device
      raise InvalidDeviceError, request.raw_post if device&.invalid?

      true
    end

    def amount_paid
      params.fetch :mc_gross
    end

    def plan
      @plan ||= Plan.where(id: params.fetch(:item_number)).take
    end

    def user
      @user ||= User::Local.where(id: params.fetch(:option_selection2)).take
    end

    def params
      @params ||= begin
                    encoding = request.params.fetch :charset
                    request.params.each_with_object({}) do |(key, param), utf8_params|
                      utf8_params[key.to_sym] = param.to_s.encode Encoding::UTF_8, encoding, invalid: :replace, undef: :replace
                    end
                  end
    end
  end
end
