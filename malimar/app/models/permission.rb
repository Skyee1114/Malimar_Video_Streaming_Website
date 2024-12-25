class Permission < ActiveRecord::Base
  ADMIN_TYPES = %i[admin supervisor agent].freeze
  TYPES = [:premium] + ADMIN_TYPES
  enum allow: TYPES

  belongs_to :subject, polymorphic: true
  scope :active, -> { where('"permissions"."expires_at" >= ?', Time.now.utc) }
  scope :expired, -> { where.not('"permissions"."expires_at" >= ?', Time.now.utc) }

  scope :for_users, -> { where(subject_type: "User::Local") }
  scope :for_devices, -> { where(subject_type: "Device") }

  def to_s
    active? ? allow
            : "expired"
  end

  def expired?
    return true unless expires_at

    expires_at < Time.now.utc
  end

  def active?
    !expired?
  end

  def allow?(permission)
    permission = permission.to_s
    permission = "premium" if permission == "adult"
    return true if permission.to_s == "premium" && ADMIN_TYPES.include?(allow.to_s.to_sym)

    allow == permission
  end

  def topup(duration)
    if active?
      self.expires_at += duration
    else
      self.expires_at = Time.now.utc + duration
    end
  end

  def revoke
    self.expires_at = Time.now.utc - 1
  end
end
