require "request_data"

class Device::ActivationRequestsController < ApiController
  def create
    build_activation
    authorize_activation

    @activation.save
    render_model @activation, status: :created
  end

  private

  def authorize_activation
    authorize @activation
  end

  def build_activation
    @activation ||= Device::ActivationRequest.new(
      activation_params.merge(ip: current_ip)
    )
  end

  def activation_params
    params.require(:activation_requests).permit(
      :first_name, :last_name,
      :email, :phone,
      :address, :city, :state, :zip, :country,
      :service, :referral
    ).tap do |attributes|
      linked_objects = params.fetch(:activation_requests).fetch :links
      attributes[:device] = linked_objects.fetch :device
    end
  end

  def current_ip
    RequestData.new(request).ip
  end
end
