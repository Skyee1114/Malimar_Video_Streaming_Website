# frozen_string_literal: true

shared_examples_for :bearer_authentication do
  let(:token_name) { raise ArgumentError }
  let(:token) { "abc" }

  describe ".get_token" do
    let(:request) { double :request, authorization: "#{token_name} #{token}" }

    it "returns the bearer token" do
      expect(subject.get_token(request)).to eq token
    end

    describe "when no authorization provided" do
      let(:request) { double :request, authorization: nil }

      it "returns nil" do
        expect(subject.get_token(request)).to be_nil
      end
    end

    describe "when another type of authorization provided" do
      let(:request) { double :request, authorization: "Basic #{token}" }

      it "returns nil" do
        expect(subject.get_token(request)).to be_nil
      end
    end
  end
end
