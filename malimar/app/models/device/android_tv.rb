class Device::AndroidTv < Device
  validates :serial_number,
            presence: true,
            length: { is: 16 },
            format: { with: /\A[a-z0-9]+\z/i, message: "Only letters and numbers are allowed" }

  def serial_number
    number = super
    return if number.nil?

    number
      .upcase
      .gsub(/o/i, "0")
  end

  def to_s
    "Android TV: #{serial_number}"
  end
end
