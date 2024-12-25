class Device::Roku < Device
  validates :serial_number,
            presence: true,
            length: { within: 6..12 },
            format: { with: /\A[a-z0-9]+\z/i, message: "Only letters and numbers are allowed" }

  def serial_number
    number = super
    return if number.nil?

    number
      .upcase
      .gsub(/o/i, "0")
  end

  def to_s
    "Roku: #{serial_number}"
  end
end
