require "null_active_record"
require_relative "types"
require_relative "../subscription"
require "global_id"
require "virtus"

module User
  class Mimic
    include NullActiveRecord
    include GlobalID::Identification
    include User::Types
    include Virtus.model

    attribute :id,            String
    attribute :login,         String
    attribute :email,         String
    attribute :subscription,  Subscription, default: :default_subscription

    def self.find(id)
      new id: id
    end

    def kind_of?(klass)
      return true if klass == User::Local

      super
    end

    private

    def default_subscription
      Subscription.new self
    end
  end
end
