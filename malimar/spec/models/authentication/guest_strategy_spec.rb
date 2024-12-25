require "support/stub_ar"
require "models/authentication/guest_strategy"

module Authentication
  describe GuestStrategy do
    subject { described_class.new request }
    let!(:request) { double :request }

    describe "#valid?" do
      describe "when authorization header is set" do
        let!(:request) { double :request, authorization: "Something" }

        it "is true" do
          expect(subject).to be_valid
        end
      end

      describe "when authorization header not set" do
        let!(:request) { double :request, authorization: nil }

        it "is true" do
          expect(subject).to be_valid
        end
      end
    end

    describe "#authenticate" do
      it "returns guest user" do
        expect(subject.authenticate).to be_guest
      end
    end
  end
end
