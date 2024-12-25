class PhoneFormatter
  def initialize(phone)
    @phone = phone
  end

  def to_us_format
    pure_numbers = phone.to_s.gsub /[^\d]/, ""
    if pure_numbers.match /\A(\d{3})(\d{3})(\d{4})\z/
      return "#{Regexp.last_match(1)}-#{Regexp.last_match(2)}-#{Regexp.last_match(3)}"
    end

    phone
  end

  private

  attr_reader :phone
end
