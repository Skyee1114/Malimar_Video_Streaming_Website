require "formatters/phone_formatter"

describe PhoneFormatter do
  subject { described_class.new phone }

  describe "#to_us_format" do
    let(:phone) { "8175289950" }
    it "formats the phone number" do
      expect(subject.to_us_format).to eq "817-528-9950"
    end

    describe "when number is unknown" do
      let(:phone) { "75289950" }

      it "returns number unaltered" do
        expect(subject.to_us_format).to eq phone
      end
    end

    describe "when number is not set" do
      let(:phone) { nil }

      it "returns number unaltered" do
        expect(subject.to_us_format).to eq phone
      end
    end
  end
end
