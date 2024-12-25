class Subscription
  def initialize(subject)
    @subject = subject
  end

  def add_time(additional_time)
    with_transaction do
      additional_time.each do |type, duration|
        add_time_for type, duration
      end
    end
  end

  def revoke
    with_transaction do
      permissions.map(&:revoke)
      permissions.map(&:save!)
    end
  end

  def has_access_to?(type)
    permission = find_permission(type)
    return false unless permission

    permission.active?
  end

  def expiration_of(type)
    permission = find_permission(type)
    permission.try(:expires_at) || Time.at(0)
  end

  private

  attr_reader :subject

  def add_time_for(type, duration)
    permission = find_permission(type) || build_permission(type)

    permission.topup duration
    permission.save!
  end

  def find_permission(type)
    permissions.detect do |permission|
      permission.allow? type.to_s
    end
  end

  def permissions
    @permissions ||= subject.permissions
  end

  def build_permission(type)
    Permission.new(
      subject: subject,
      allow: type
    )
  end

  def with_transaction
    ActiveRecord::Base.transaction do
      yield
    end
  end
end
