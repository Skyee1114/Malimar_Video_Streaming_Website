require_relative "../subscription"

class Subscription::Free < Subscription
  def add_time(*); end

  def has_access_to?(*)
    false
  end

  def expiration_of(*)
    Time.at(0)
  end

  def revoke(*); end
end
