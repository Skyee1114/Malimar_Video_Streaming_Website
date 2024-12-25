require_relative "../loader"

module Loader
  class RemoteResource
    def self.load(data, **attributes)
      loader = new(data, **attributes)
      loader.validate
      loader.load
    end

    def initialize(remote_resource)
      @remote_resource = remote_resource
    end

    def record
      @record ||= remote_resource.to_h
    end

    def valid?
      record["Mweb"] != "N"
    end

    def validate
      raise LoadError unless valid?
    end

    def load
      raise NotImplementedError
    end

    def defaults
      {
        content_type: content_type,
        container: container
      }
    end

    private

    attr_reader :remote_resource

    def content_type
      remote_resource.content_type
    end

    def container
      Resource::Feed.new url: remote_resource.source
    end

    def recently_updated_record?
      !!updated_at && (updated_at > date_treshold)
    end

    def updated_at
      @updated_at ||=
        if record["description"] =~ /Updated On: (.+?) with/i
          Date.strptime(Regexp.last_match(1), "%d-%b-%Y").in_time_zone("Pacific Time (US & Canada)")
        end
    end

    def date_treshold
      1.day.ago
    end

    def provider_name(record)
      record["WTOKEN"].to_s.present? ? record["WTOKEN"]
                                     : record["MTOKEN"]
    end

    def stream_url(media)
      webstreamUrl = media["webstreamUrl"].to_s
      if webstreamUrl.include?("http")
        media["webstreamUrl"]
      else
        media["streamUrl"]
      end
    end
  end
end
