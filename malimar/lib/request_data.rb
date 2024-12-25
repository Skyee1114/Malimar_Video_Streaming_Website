class RequestData
  extend Forwardable
  def_delegators :user_agent, :platform, :os
  def_delegator :user_agent, :version, :browser_version
  def_delegator :user_agent, :name, :browser_name

  attr_reader :request

  def initialize(request)
    @request = request
  end

  def ip
    request.remote_ip
  end

  def env
    request.env
  end

  private

  def user_agent
    @user_agent ||= ::UserAgent.new env.fetch "HTTP_USER_AGENT", ""
  end
end
