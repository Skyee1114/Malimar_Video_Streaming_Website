require "rails_helper"
require "factories/device/roku"

describe Device::Roku do
  subject { described_class }

  describe "#serial_number" do
    it "upcases input" do
      id = subject.new serial_number: "AbC123d"
      expect(id.serial_number).to eq "ABC123D"
    end

    it "limited to be in range from 6 to 12 chars" do
      expect(subject.new(serial_number: "AbC12")).to be_invalid
      expect(subject.new(serial_number: "AbC123")).to be_valid
      expect(subject.new(serial_number: "AbC123dab")).to be_valid
      expect(subject.new(serial_number: "123456789012")).to be_valid
      expect(subject.new(serial_number: "1234567890123")).to be_invalid
    end

    it "does not allow non alpha chars" do
      expect(subject.new(serial_number: "12345678901^^")).to be_invalid
      expect(subject.new(serial_number: "1234€6789012")).to be_invalid
    end

    it "replaces letter O by zero" do
      id = subject.new serial_number: "123456789O12"
      expect(id).to be_valid
      expect(id.serial_number).to eq "123456789012"
    end

    describe "when nil" do
      it "returns nil" do
        id = subject.new serial_number: nil
        expect(id.serial_number).to be_nil
      end
    end
  end

  describe "#destroy" do
    it "deletes permissions as well" do
      device = create :roku_device, :premium

      expect do
        device.destroy
      end.to change { Permission.count }.by -1
    end
  end
end
