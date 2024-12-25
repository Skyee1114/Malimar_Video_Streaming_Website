require "rails_helper"
require "support/wisper"
require "factories/device/activation_request"
require "factories/device/black_list_entry"

describe Device::ActivationRequest do
  describe "on successful activation" do
    subject { build :device_activation_request }
    it "emits a new_device_activation event" do
      expect { subject.save }.to broadcast :new_device_activation
    end
  end

  describe "when invalid" do
    subject { build :device_activation_request, email: "invalid" }

    it "does not emit an event" do
      expect { subject.save }.not_to broadcast :new_device_activation
    end
  end

  describe "when device id is invalid" do
    subject { build :device_activation_request, device: { serial_number: "a$b", type: "Device::Roku" } }

    it "does not emit an event" do
      expect { subject.save }.not_to broadcast :new_device_activation
    end
  end

  describe "when device id is blacklisted" do
    subject { build :device_activation_request, device: { serial_number: black_list_entry.serial_number } }
    let(:black_list_entry) { create :device_black_list_entry }

    it "does not emit an event" do
      expect { subject.save }.not_to broadcast :new_device_activation
    end
  end
end
