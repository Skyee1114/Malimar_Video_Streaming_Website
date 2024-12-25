# frozen_string_literal: true

module WebClient::DomainHelper
  def domain
    ENV["DOMAIN"]
  end

  def company_name
    ENV["COMPANY_NAME"]
  end

  def support_email
    ENV["SUPPORT_EMAIL"]
  end
end
