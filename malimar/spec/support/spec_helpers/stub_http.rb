module SpecHelpers
  module StubHttp
    def stub_http(method, url, body)
      Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.send(method, url) { [200, {}, body] }
        end
      end
    end
  end
end
