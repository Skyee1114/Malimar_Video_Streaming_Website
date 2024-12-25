require "support/active_serializer_support"
require "models/loader/remote_resource"
require "models/remote_resource"
require_relative "../loader_examples"

describe Loader::RemoteResource do
  it_behaves_like :loader

  subject { described_class.new resource }
  let(:resource) { double(:resource, to_h: {}) }

  describe "#recently_updated?" do
    let(:resource) do
      spy(RemoteResource, feed_type: "episodes", has_field?: true, to_h: resource_attributes)
    end

    let(:recently_updated) { subject.send :recently_updated_record? }

    describe "for recent resource" do
      let(:resource_attributes) do
        {
          "description" => "Updated On: #{Time.now.strftime('%d-%b-%Y')} with 23 Episode(s) Plays On: Everyday Language: Lao Language: Lao",
          "feed" => "http://example.com/123resource.xml"
        }
      end

      it "is true" do
        expect(recently_updated).to eq true
      end
    end

    describe "for not updated resource" do
      let(:resource_attributes) do
        {
          "description" => "Updated On: #{5.days.ago.strftime('%d-%b-%Y')} with 23 Episode(s) Plays On: Everyday Language: Lao Language: Lao",
          "feed" => "http://example.com/123resource.xml"
        }
      end
      it "is false" do
        expect(recently_updated).to eq false
      end
    end

    describe "timezone aware" do
      let(:resource_attributes) do
        {
          "description" => "Updated On: #{updated_at.strftime('%d-%b-%Y')} with 23 Episode(s) Plays On: Everyday Language: Lao Language: Lao",
          "feed" => "http://example.com/123resource.xml"
        }
      end
      let(:updated_at) { DateTime.parse "2 Feb 2015" }

      before do
        allow(subject).to receive(:date_treshold).and_return date_treshold
      end

      describe "when updated recently" do
        let(:date_treshold) { DateTime.parse "1 Feb 2015 23:00:00-8:00" }

        it "is true" do
          expect(recently_updated).to eq true
        end
      end

      describe "when updated recently but in wrong timezone" do
        let(:date_treshold) { DateTime.parse "1 Feb 2015 23:00:00-10:00" }

        it "is true" do
          expect(recently_updated).to eq false
        end
      end

      describe "when updated recently but time defined in another timezone" do
        let(:date_treshold) { DateTime.parse "2 Feb 2015 01:00:00-6:00" }

        it "is true" do
          expect(recently_updated).to eq true
        end
      end
    end
  end

  describe "#valid?" do
    it "is true" do
      expect(subject).to be_valid
    end

    describe "for displayed resource" do
      let(:resource) { double(:resource, to_h: { "Mweb" => "Y" }) }

      it "is true" do
        expect(subject).to be_valid
      end
    end
  end
end
