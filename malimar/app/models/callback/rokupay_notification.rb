require "wisper"
require "form/load_links"

module Callback
  class RokupayNotification
    include Wisper.publisher
    include ActiveModel::Validations
    include ActiveModel::SerializerSupport

    attr_reader :plan

    Error = Class.new StandardError

    NotTrustedCallbackError = Class.new Error

    InvalidUserError = Class.new Error
    InvalidBillingAddressError = Class.new Error
    InvalidDeviceError = Class.new Error

    InvalidPlanError = Class.new Error
    InvalidAmountError = Class.new Error
    RefundError = Class.new Error

    class ValidAddress < ::BillingAddress
      validates_presence_of(
        :first_name, :last_name,
        :email, :phone,
        :country
      )

      validates_length_of :first_name, :last_name, maximum: 200
      validates_length_of :phone,                  minimum: 8, maximum: 30
      validates_length_of :email,                  maximum: 200
      validates_length_of :country,                is: 2

      validates :email, email: true
    end

    def initialize(request)
      @request = request

      @user_params = normalize_user_params
      @device_params = normalize_device_params
      @billing_address_params = normalize_billing_address_params
      @plan_params = normalize_plan_params

      @plan = load_plan
    end

    def save
      return false unless valid?

      user = load_user
      billing_address = load_billing_address(user: user)
      device = load_device(user: user)
      transaction = create_transaction(billing_address: billing_address, user: user)

      activate_subscription(user: user, device: device)
      broadcast :successful_transaction, transaction
    rescue Error, KeyError
      broadcast :rokupay_payment_error, $!.class.name, $!.message
      false
    end

    def valid?
      return false unless feature_active? :payments

      validate_roku_payment
      validate_bussiness_address
      validate_plan
      validate_user
      validate_device

      errors.none?
    rescue RefundError
      false
    rescue Error, KeyError
      broadcast :rokupay_payment_error, $!.class.name, $!.message
      false
    end

    def attributes
      [
        :plan
      ]
    end

    private

    attr_reader :request, :user_params, :device_params, :billing_address_params, :plan_params

    def activate_subscription(user:, device:)
      subscribe SubscriptionActivator.new(plan, user, device)
    end

    def create_transaction(billing_address:, user:)
      Transaction.create_from_rokupay(
        billing_address: billing_address,
        user: user,
        fields: params
      )
    end

    def normalize_user_params
      user = linked_objects[:user]
      return {} if user.blank?

      {
        email: "test@example.com"
        # email: user.fetch(:email)
      }
    end

    def validate_user
      errors.add(:user, "Invalid user email") if user_params.fetch(:email).blank?
    end

    def load_user
      email = user_params.fetch(:email)
      find_user(email) || create_user(email)
    end

    def normalize_device_params
      device = linked_objects[:device]
      return if device.blank?

      # serial_number = device.fetch(:serial_number)
      serial_number = "4114AC001000"
      type = device.fetch(:type)
      return if [nil, "", "N/A"].include? serial_number

      {
        serial_number: serial_number,
        type: type
      }
    end

    def validate_device
      device = Device.new(device_params)
      errors.add(:device, device.errors) if device.invalid?
    end

    def load_device(user:)
      type = device_params.fetch(:type)
      serial_number = device_params.fetch(:serial_number)

      if type.present?
        Device.where(serial_number: serial_number, type: type).take \
          || Device.where(serial_number: serial_number).take \
          || Device.create(serial_number: serial_number, user: user, type: type)
      else
        Device.where(serial_number: serial_number).take \
          || Device.create(serial_number: serial_number, user: user)
      end
    rescue KeyError
      nil
    end

    def normalize_billing_address_params
      linked_objects[:billing_address] || {}
    end

    def validate_bussiness_address
      valid_address = ValidAddress.new(billing_address_params)
      errors.add(:billing_address, valid_address.errors) unless valid_address.valid?
    end

    def load_billing_address(user:)
      billing_params = billing_address_params
      billing_params[:user_id] = user.id

      BillingAddress.where(billing_params).first_or_create
    end

    def normalize_plan_params
      plan_params = linked_objects[:plan]

      {
        id: plan_params
      }
    end

    def validate_plan
      errors.add(:plan, "doesn't exist") && return unless plan
      errors.add(:plan, "was refunded") if amount_paid == "-#{plan.cost}"
      errors.add(:plan, "payment of #{amount_paid} doesn't match plan cost of #{plan.cost}") unless amount_paid == plan.cost
    end

    def validate_roku_payment
      errors.add(:origin, "is was not confirmed") unless true
    end

    def amount_paid
      params.fetch :amount
    end

    def load_plan
      Plan.where(id: plan_params.fetch(:id)).take
    end

    def user
      @user ||= find_user(params.fetch(:payer_email))
    end

    def params
      @params ||= ActiveSupport::HashWithIndifferentAccess.new(request.params.fetch("rokupay_notifications"))
    end

    def linked_objects
      @linked_objects ||= params.fetch(:links)
    end

    def find_user(email)
      User::Local.where(login: email).take
    end

    def create_user(email)
      current_user = User::Invited.new id: email

      User::Local.new(login: email, email: email).tap do |user|
        policy = User::LocalPolicy.new current_user, user
        raise Pundit::NotAuthorizedError.new(query: :create?, record: user, policy: policy) unless policy.create?

        user.save!
      end
    rescue ActiveRecord::RecordInvalid
      raise Error, $!
    end
  end
end
