require "support/active_serializer_support"
require "models/loader/show"
require_relative "../loader_examples"

describe Loader::Show do
  it_behaves_like :loader

  subject { described_class.new resource }
  let(:resource) { spy :resource }

  describe "#load" do
    it "returns Container" do
      expect(subject.load).to be_a Resource::Container
    end
  end

  describe "#valid?" do
    it "is true when resource has a feed episodes key" do
      allow(resource).to receive(:has_field?).with("feed").and_return true
      allow(resource).to receive(:feed_type).and_return "episodes"
      expect(subject).to be_valid
    end

    it "is false when resource hasn't a feed key" do
      allow(resource).to receive(:has_field?).with("feed").and_return false
      expect(subject).not_to be_valid
    end

    it "is false when resource has different feed key" do
      allow(resource).to receive(:has_field?).with("feed").and_return true
      allow(resource).to receive(:feed_type).and_return "grids"
      expect(subject).not_to be_valid
    end
  end
end
