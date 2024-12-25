module Callback
  class PaymentNotificationsController < CallbacksController
    def create
      build_notification
      @notification.save
      head :ok
    end

    private

    def build_notification
      @notification = PaymentNotification.new request
    end
  end
end
