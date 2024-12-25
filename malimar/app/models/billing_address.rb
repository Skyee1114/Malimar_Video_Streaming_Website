class BillingAddress < ActiveRecord::Base
  has_many :transactions
  belongs_to :user, class_name: "User::Local"

  def to_s
    "#{name}:#{country}:#{zip}"
  end

  def name
    [first_name, last_name].reject(&:blank?).join " "
  end

  def country_code
    code = ISO3166::Country[country].try :country_code
    return unless code

    "+#{code}"
  end

  def to_hash
    attributes.to_h
  end
end
