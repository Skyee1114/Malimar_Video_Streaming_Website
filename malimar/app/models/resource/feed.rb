require "virtus"

module Resource
  class Feed
    include Virtus.value_object
    include ActiveModel::SerializerSupport

    values do
      attribute :id,   String, default: :build_id
      attribute :url,  String, default: :build_url
    end

    def valid?
      valid_id? && valid_url?
    end

    private

    def build_url
      raise NotFoundError unless valid_id?
      return ENV["HOME_URL"] if %w[Home HomeGrid].include? id

      "#{ENV['HOME_FOLDER']}#{File.basename id}.xml"
    end

    def build_id
      File.basename url, File.extname(url)
    end

    def valid_id?
      id.present? &&
        !id.include?("..")
    end

    def valid_url?
      url.present? &&
        !url.include?("..")
    end
  end
end
