require "aws-sdk"

class Device::ActivationUploader
  class << self
    def new_device_activation(activation, *_rest)
      upload_device_serial activation.serial_number
    end

    def new_device_subscription_payment(device, *_rest)
      upload_device_serial device.serial_number
    end

    private

    def upload_device_serial(serial_number)
      upload_to_s3 name: serial_number unless Rails.env.development?
    end

    def upload_to_s3(name:)
      s3.bucket(bucket_name).object(location(name)).put acl: "public-read"
    end

    def s3
      @s3 ||= Aws::S3::Resource.new
    end

    def bucket_name
      ENV["ROKU_ACTIVATION_BUCKET"]
    end

    def location(serial)
      "Roku/SERIAL/#{serial}"
    end
  end
end
