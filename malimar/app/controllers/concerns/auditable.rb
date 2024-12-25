require "request_data"

module Auditable
  private

  def current_ip
    RequestData.new(request).ip
  end
end
