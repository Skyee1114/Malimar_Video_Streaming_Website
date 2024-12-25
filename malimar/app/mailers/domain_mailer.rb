class DomainMailer < ActionMailer::Base
  add_template_helper EmailImageHelper
  layout "email"
  TECH_EMAIL = "alex@crasome.com".freeze

  helper_method :domain
  def domain
    ENV["DOMAIN"]
  end

  helper_method :company_name
  def company_name
    ENV["COMPANY_NAME"]
  end

  helper_method :support_email
  def support_email
    ENV["SUPPORT_EMAIL"]
  end
end
