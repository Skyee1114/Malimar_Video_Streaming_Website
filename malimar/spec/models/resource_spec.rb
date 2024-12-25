require "support/active_serializer_support"
require "support/spec_helpers/stub_http"
require "models/resource"
require "factories/resource/feed"

describe Resource do
  include SpecHelpers::StubHttp
  include FactoryGirl::Syntax::Methods

  before(:each) do
    allow_any_instance_of(DB).to receive(:with_cache).and_yield
    allow_any_instance_of(DB).to receive(:connection).and_return connection
  end

  let(:url) { "http://example.com/file.xml" }
  let(:feed) { build :feed, url: url }

  let(:connection) { stub_http :get, url, remote_xml }
  let(:remote_xml) do
    '
<feed>
  <item>
    <title>ROW 1 Live TV | Free</title>
    <feed>
      https://malimartv.s3.amazonaws.com/roku/xml/Home/LiveTV_Free_CF.xml
    </feed>
  </item>
  <item>
    <title>ROW 2 Premium View</title>
    <feed>
      https://malimartv.s3.amazonaws.com/roku/xml/Home/Premium_View_CF.xml
    </feed>
    <authorizationURL>https://s3.amazonaws.com/aseaniptv/Roku/SERIAL/</authorizationURL>
  </item>
  <item>
    <title>ROW 3 Live TV | Premium</title>
    <feed>
      https://malimartv.s3.amazonaws.com/roku/xml/Home/LiveTV_Premium_CF.xml
    </feed>
    <authorizationURL>https://s3.amazonaws.com/aseaniptv/Roku/SERIAL/</authorizationURL>
  </item>
</feed>'
  end

  describe ".all" do
    describe "limit" do
      it "limits the amount of resources returned" do
        expect(subject.all(feed, limit: 2).count).to eq 2
      end

      describe "when string given" do
        it "converts it to the integer" do
          expect(subject.all(feed, limit: "2").count).to eq 2
        end
      end

      describe "when empty given" do
        it "ignores it" do
          ["", nil].each do |empty_value|
            expect(subject.all(feed, limit: empty_value).count).to eq 3
          end
        end
      end
    end

    describe "when get invalid ids" do
      let(:url_with_invalid_feed) { "http://example.com/a b c d.xml" }
      let(:feed) { build :feed, url: url_with_invalid_feed }

      it "raises NotFoundError" do
        expect do
          subject.all feed
        end.to raise_error(described_class::NotFoundError)
      end
    end

    describe "when try to read content from another directory" do
      let(:url_with_dots) { "http://example.com/public/../secret/abc.xml" }
      let(:feed) { build :feed, url: url_with_dots }

      it "raises NotFoundError" do
        expect do
          subject.all feed
        end.to raise_error(described_class::NotFoundError)
      end
    end

    describe "when several feeds provided" do
      let(:feeds) { build_list :feed, 2 }

      it "loads resources from all feeds" do
        expect(DB).to receive(:new).with(feeds.first.url).and_return double(resources: [1, 2])
        expect(DB).to receive(:new).with(feeds.last.url).and_return double(resources: [3, 4])

        expect(Loader::Collection).to receive(:new).with([1, 2]).and_return double(all: %i[one two])
        expect(Loader::Collection).to receive(:new).with([3, 4]).and_return double(all: %i[three four])

        expect(subject.all(feeds)).to eq %i[one two three four]
      end
    end
  end

  describe ".find" do
    it "lazy loads resources" do
      expect(Loader::Grid).to receive(:new).exactly(2).times.and_call_original

      subject.find "Premium_View_CF", feed
    end

    describe "when several feeds provided" do
      let(:feeds) { build_list :feed, 2 }

      it "finds element in second feed" do
        expect(DB).to receive(:new).with(feeds.first.url).and_return double(resources: [1, 2])
        expect(DB).to receive(:new).with(feeds.last.url).and_return double(resources: [3, 4])

        resource = double(id: :four)
        expect(Loader::Collection).to receive(:new).with([1, 2]).and_return double(all: [spy])
        expect(Loader::Collection).to receive(:new).with([3, 4]).and_return double(all: [resource])
        expect(subject.find(:four, feeds)).to eq resource
      end

      it "lazy loads feeds" do
        expect(DB).to receive(:new).with(feeds.first.url).and_return double(resources: [1, 2])
        expect(DB).not_to receive(:new).with(feeds.last)

        resource = double(id: :one)
        expect(Loader::Collection).to receive(:new).with([1, 2]).and_return double(all: [resource])
        expect(subject.find(:one, feeds)).to eq resource
      end
    end
  end
end
