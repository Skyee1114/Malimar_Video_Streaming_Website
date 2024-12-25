shared_examples_for :loader do
  it "responds to .load" do
    expect(described_class).to respond_to :load
  end

  it "responds to #valid?" do
    expect(subject).to respond_to :valid?
  end

  it "responds to #validate" do
    expect(subject).to respond_to :validate
  end

  describe "for hidden resource" do
    describe "#valid?" do
      let(:resource) { double(:resource, to_h: { "Mweb" => "N" }) }

      it "is false" do
        expect(subject).not_to be_valid
      end
    end
  end
end
