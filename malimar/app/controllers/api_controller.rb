require "array_serializer"

class ApiController < ::ApplicationController
  around_action :listen_to_wisper

  include Authentication

  include SerializerSupport
  include JsonApiRenderable
  include Policy
  include ActionCacheable
  include Filterable
  include Auditable
  include Wisper.publisher

  rescue_from(Pundit::NotAuthorizedError) { head :forbidden }
  rescue_from(Resource::NotFoundError,
              ActiveRecord::RecordNotFound) { head :not_found }

  rescue_from(Authentication::PolicyError) { head :conflict }

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  private

  def feed(id)
    Resource::Feed.new id: id
  end

  def authentication_strategies
    [
      Authentication::TokenStrategy.new(request, encoder_key: Rails.application.secrets.secret_key_base)
    ]
  end

  def listen_to_wisper
    Wisper.subscribe(
      Device::ActivationUploader,
      NewSubscriptionEmailer,
      RollbarReporter,
      async: true
    ) { yield }
  end
end
