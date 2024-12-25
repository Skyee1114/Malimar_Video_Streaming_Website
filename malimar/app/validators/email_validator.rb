class EmailValidator < ActiveModel::EachValidator
  def self.valid?(email)
    email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  end

  def validate_each(record, attribute, value)
    return if self.class.valid? value
    return if record.errors.added? attribute, error_message

    record.errors.add attribute, error_message
  end

  private

  def error_message
    options[:message] || "should be a valid email address so we can contact you back"
  end
end
