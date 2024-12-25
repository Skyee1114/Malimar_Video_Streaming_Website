class Device < ActiveRecord::Base
  has_many :permissions, as: :subject, dependent: :destroy

  belongs_to :user, class_name: "User::Local"
  scope :for_user, ->(user) { where(user: user) }

  scope :premium, -> { joins(:permissions).where(["permissions.expires_at > ?", Time.now.utc]) }
  scope :free, -> { eager_load(:permissions).where(["permissions.expires_at <= ? OR permissions.expires_at IS NULL", Time.now.utc]) }

  def subscription
    @subscription ||= Subscription.new(self)
  end

  def name
    type
  end

  def to_hash
    attributes.to_h
  end

  def to_s
    "Device: #{serial_number}"
  end

  def blacklisted?
    Device::BlackListEntry.where(serial_number: serial_number).any?
  end

  def validate_blacklist
    return true unless blacklisted?

    errors.add(:serial_number, "Your serial number is not compatible with our services call or email our customer service.")
    false
  end
end
