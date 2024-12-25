require "rails_helper"
require "factories/resource/video"
require "factories/rewrite_rule"

describe PlayableUrl do
  before { UrlTokenizer.register "Wowza" => token_provider }

  subject { described_class.new video_stream, stream_server: stream_server }
  let(:video_stream) { double url: source_url, provider: "Wowza" }
  let(:source_url) { "http://example.com/stream/playlist.m3u8" }
  let(:stream_server) { nil }
  let(:token_provider) { UrlTokenizer::Wowza.new("secret") }

  describe "#url" do
    it "makes url securely available for public" do
      expect(subject.url).to include "wowzatokenhash"
    end

    it "adds token to url" do
      expect(subject.url).to match /wowzatokenhash=.+/
    end

    describe "Limelight" do
      before { UrlTokenizer.register "LL" => ll_provider }
      let(:video_stream) { double url: source_url, provider: "LL" }
      let(:ll_provider) { UrlTokenizer::Limelight.new("secret", cf: 100) }

      it "uses cookie auth" do
        expect(subject.url).to include "cf="
      end
    end

    describe "CDN77" do
      before { UrlTokenizer.register "CDN77" => cdn77_provider }
      let(:video_stream) { double url: source_url, provider: "CDN77" }
      let(:cdn77_provider) { UrlTokenizer::CDN77.new("secret") }

      it "adds token to url" do
        expect(subject.url).to match /secure=.+/
      end
    end

    describe "stream_server rewrite" do
      let(:video) { build :channel, :tea_tv, :liveplay }
      let(:source_url) { video.video_stream.url }
      let(:stream_server) { "https://subdomain.domain.co.uk" }

      it "changes the host and scheme" do
        expect(subject.url).to match %r{^https://subdomain\.domain\.co\.uk}
      end

      describe "liveplay n server" do
        let(:source_url) { "http://liveplay4.malimarcdn.com/stream/playlist.m3u8" }

        it "does not rewrite" do
          expect(subject.url).to include "http://liveplay4.malimarcdn.com"
        end
      end

      describe "liveplay server on another domain" do
        let(:source_url) { "http://liveplay.malimarcdn.com/stream/playlist.m3u8" }

        it "does not rewrite" do
          expect(subject.url).not_to include "subdomain"
        end
      end

      describe "with / at the end" do
        let(:stream_server) { "http://domain.com/" }

        it "ignores trailing /" do
          expect(subject.url).to include "http://domain.com/"
          expect(subject.url).not_to match %r{http://domain\.com//}
        end
      end

      describe "does not alter vod videos" do
        let(:video) { build :episode }
        let(:stream_server) { "http://somedomain.com" }

        it "does not change the url" do
          expect(subject.url).not_to include "somedomain"
        end
      end
    end

    describe "rewrite rules" do
      before do
        LocalCache.clear!
      end

      it "applies rewrite rules" do
        create :rewrite_rule, :url, from: "example", to: "rewritten"

        expect(subject.url).to match %r{^http://rewritten.com/stream/playlist.m3u8}
      end

      it "does not apply non url rules" do
        create :rewrite_rule, :image, from: "example", to: "rewritten"

        expect(subject.url).to match %r{^http://example.com/stream/playlist.m3u8}
      end
    end
  end

  describe ".playable?" do
    it "true for playable url" do
      expect(described_class.playable?(subject.url)).to be_truthy
    end

    it "false for other url" do
      expect(described_class.playable?("http://example.com/playlist.m3u")).to be_falsey
    end
  end
end
