require "support/active_serializer_support"
require "models/loader/episode"
require_relative "../loader_examples"

describe Loader::Episode do
  it_behaves_like :loader

  subject { described_class.new resource }
  let(:resource) { spy :resource }

  describe "#load" do
    it "returns Video" do
      expect(subject.load).to be_a Resource::Video
    end
  end

  describe "#valid?" do
    it "is true when resource has an episodeNumber" do
      allow(resource).to receive(:has_field?).with("episodeNumber").and_return true
      expect(subject).to be_valid
    end

    it "is false when resource hasn't a media key" do
      allow(resource).to receive(:has_field?).with("episodeNumber").and_return false
      expect(subject).not_to be_valid
    end
  end
end
