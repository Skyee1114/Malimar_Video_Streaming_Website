class DevicesController < ApiController
  def index
    load_user
    load_devices
    render json: @devices
  end

  def show
    load_device
    authorize_device

    render_model @device, except: :href
  end

  def create
    load_user
    build_device
    authorize_device

    location = nil
    location = device_url(@device) if @device.save

    render_model @device, except: :href, status: :created, location: location
  end

  def update
    load_device
    authorize_device
    build_device

    @device.save
    render_model @device, except: :href
  end

  private

  def load_user
    @user = User::Local.find params[:user] || user_id
  rescue ActiveRecord::RecordNotFound
    raise Pundit::NotAuthorizedError
  end

  def load_devices
    @devices = policy_scope(
      Device.for_user(@user),
      policy: DevicePolicy
    )
  end

  def load_device
    @device = Device.find params[:id], params[:type]
  end

  def authorize_device
    authorize @device, policy: DevicePolicy
  end

  def build_device
    @device ||= Device.new(
      user: @user,
      serial_number: device_params.fetch(:serial_number),
      type: device_params.fetch(:type),
      name: device_params.fetch(:name, nil)
    )
  end

  def device_params
    params.require(:devices).permit(:name, :serial_number, :type)
  end

  def user_id
    params.require(:devices).require(:links).fetch(:user)
  end
end
