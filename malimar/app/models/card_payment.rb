require "virtus"

class CardPayment
  include Virtus.value_object

  values do
    attribute :amount,           String
    attribute :description,      String
    attribute :invoice,          String,         default: ""
    attribute :custom_fields,    Hash,           default: {}

    attribute :card,             Card
    attribute :billing_address,  BillingAddress
  end
end
