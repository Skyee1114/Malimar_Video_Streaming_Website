require "support/active_serializer_support"
require "models/loader/collection"

describe Loader::Collection do
  subject { described_class.new list, loaders: loaders }
  let(:list) { [1, 2] }

  let(:loaders)      { [loader_class] }
  let(:loader_class) { double :loader_class, new: loader }
  let(:loader)       { double :loader, load: resource }
  let(:resource)     { double :resource }

  describe "#all" do
    it "return lazy enumerator" do
      expect(subject.all).to be_a Enumerator::Lazy
    end

    it "loads each resource" do
      allow(loader).to receive(:valid?).and_return true

      expect(loader_class).to receive(:new).with(1).once.and_return(loader)
      expect(loader_class).to receive(:new).with(2).once.and_return(loader)

      expect(subject.all.to_a).to all eq resource
    end

    describe "when several loaders available" do
      let(:loaders) do
        [
          loader_class,
          another_loader_class
        ]
      end
      let(:another_loader_class) { double :another_loader_class, new: another_loader }
      let(:another_loader)       { double :another_loader, load: another_resource }
      let(:another_resource)     { double :another_resource }

      it "loads each resource using corresponding loader" do
        allow(loader).to receive(:valid?).and_return false, true
        allow(another_loader).to receive(:valid?).and_return true

        expect(subject.all.to_a).to eq [another_resource, resource]
      end
    end

    describe "when unable to find suitable loader" do
      let(:loaders) { [] }

      it "returns empty array" do
        expect(subject.all.to_a).to be_empty
      end
    end
  end
end
