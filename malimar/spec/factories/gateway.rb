require "factory_girl"

FactoryGirl.define do
  factory :authorize_net_gateway, class: PaymentGateway::AuthorizeNet do
  end
end
