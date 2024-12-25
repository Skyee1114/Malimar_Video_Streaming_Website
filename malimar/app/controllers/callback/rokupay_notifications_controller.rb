module Callback
  class RokupayNotificationsController < CallbacksController
    include Wisper.publisher
    include SerializerSupport
    include JsonApiRenderable
    include Auditable

    def create
      build_notification
      @notification.save

      render_model @notification, status: :created
    end

    private

    def build_notification
      @notification = RokupayNotification.new request
    end
  end
end
