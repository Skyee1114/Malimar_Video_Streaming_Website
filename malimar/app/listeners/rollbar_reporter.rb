class RollbarReporter
  class << self
    unless Rails.env.development?
      def paypal_payment_error(exception_name, raw_post_data)
        require "rollbar"
        Rollbar.error "#{exception_name}: #{raw_post_data}"
      end

      def rokupay_payment_error(exception_name, raw_post_data)
        require "rollbar"
        Rollbar.error "#{exception_name}: #{raw_post_data}"
      end
    end
  end
end
