class StatusController < ApplicationController
  def index
    render json: {
      name: Rails.application.class.parent_name,
      requested_at: Time.now,
      status: "ok"
    }
  end
end
