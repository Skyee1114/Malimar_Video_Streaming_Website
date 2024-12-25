shared_examples_for :bearer_strategy do
  let(:token_name) { raise ArgumentError }
  let(:token) { "abc" }

  describe "#valid?" do
    describe "when bearer header is set" do
      let(:request) { double :request, authorization: "#{token_name} something" }

      it "is true" do
        expect(subject).to be_valid
      end
    end

    describe "when bearer header set but is nil" do
      let!(:request) { double :request, authorization: token_name }

      it "is true" do
        expect(subject).to be_valid
      end
    end

    describe "when bearer header set but is empty" do
      let!(:request) { double :request, authorization: "#{token_name} " }

      it "is true" do
        expect(subject).to be_valid
      end
    end

    describe "when bearer header not set" do
      let!(:request) { double :request, authorization: "something" }

      it "is false" do
        expect(subject).not_to be_valid
      end
    end

    describe "when authorization header not set" do
      let!(:request) { double :request, authorization: nil }

      it "is false" do
        expect(subject).not_to be_valid
      end
    end
  end

end
