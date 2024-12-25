require "virtus"

class Card
  include Virtus.value_object

  values do
    attribute :number,       String
    attribute :cvv,          String
    attribute :expiry_date,  Date, default: :build_expiry_date

    attribute :expiry_month, Integer
    attribute :expiry_year,  Integer
  end

  private

  def build_expiry_date
    return if [expiry_year, expiry_month].any? &:blank?

    Date.new expiry_year, expiry_month
  end
end
