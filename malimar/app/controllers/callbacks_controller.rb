class CallbacksController < ::ActionController::Base
  around_action :listen_to_wisper

  private

  def listen_to_wisper
    Wisper.subscribe(
      Device::ActivationUploader,
      NewSubscriptionEmailer,
      RollbarReporter,
      async: true
    ) { yield }
  end
end
