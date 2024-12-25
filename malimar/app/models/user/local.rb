require_relative "../../validators/email_validator"
require_relative "types"
require "wisper"

module User
  class Local < ActiveRecord::Base
    include User::Types
    include Wisper.publisher
    self.table_name = :users

    validates :login, presence: true,
                      length: { maximum: 200 }, allow_blank: false

    validates :email, presence: true,
                      email: true,
                      length: { maximum: 200 }, allow_blank: false

    scope :with_email, ->(email) { where "email = ? OR id = ?", email, email }

    has_many :permissions,        as: :subject,           dependent: :destroy
    has_many :billing_addresses,  foreign_key: :user_id,  dependent: :nullify
    has_many :transactions,       foreign_key: :user_id,  dependent: :nullify
    has_many :devices,            foreign_key: :user_id,  dependent: :nullify, class_name: "Device"

    scope :expire_soon, -> { premium.where(["permissions.expires_at < ?", Time.now.utc + 10.days]) }
    scope :premium, -> { joins(:permissions).where(["permissions.expires_at > ?", Time.now.utc]) }
    scope :free, -> { eager_load(:permissions).where(["permissions.expires_at <= ? OR permissions.expires_at IS NULL", Time.now.utc]) }
    scope :with_devices, -> { joins(:devices).where.not("devices.id" => nil) }

    after_commit :publish_creation_successful, on: :create

    def self.model_name
      @_model_name ||= ActiveModel::Name.new self, nil, User.name
    end

    def kind_of?(klass)
      return true if klass == User::Mimic

      super
    end

    def subscription
      @subscription ||= Subscription.new(self)
    end

    def ==(other)
      super unless other.respond_to? :login
      other.login == login
    end

    def to_s
      email
    end

    def name
      billing_addresses.any? ? billing_addresses.max_by(&:created_at).name
                             : login
    end

    private

    def publish_creation_successful
      broadcast :user_created, self
    end
  end
end
