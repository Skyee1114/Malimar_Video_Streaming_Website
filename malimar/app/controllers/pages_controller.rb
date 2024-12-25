class PagesController < ApplicationController
  include Authentication
  before_action :force_html_format

  def home; end

  def wip
    render layout: false
  end

  private

  def authentication_strategies
    return [] unless feature_active? :beta

    # Use strategies below to disable templates load
    [
      Authentication::InvitationStrategy.new(request, encoder_key: Rails.application.secrets.secret_key_base),
      Authentication::LoginStrategy.new(request)
    ]
  end

  def force_html_format
    request.format = "html"
  end
end
