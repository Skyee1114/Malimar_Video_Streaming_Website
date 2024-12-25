class Device::ActivationPresenter < SimpleDelegator
  def service
    case super
    when "trial" then "30 Day trial activation request"
    when "tech" then "Technical support"
    end
  end

  def deactivation_date
    30.days.from_now.strftime "%D"
  end

  def phone
    return super unless %w[US CA].include? country

    PhoneFormatter.new(super).to_us_format
  end
end
