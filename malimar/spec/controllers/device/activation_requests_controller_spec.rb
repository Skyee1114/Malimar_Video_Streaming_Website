require "rails_helper"
require "support/shared_examples/requests"
require "factories/user"
require "factories/device/activation_request"
require "factories/device/black_list_entry"
require "aws-sdk"

describe Device::ActivationRequestsController do
  include SpecHelpers::Email
  before :context do
    Aws.config[:access_key_id] = "key"
    Aws.config[:secret_access_key] = "secret"

    WebMock.stub_request(:put, "https://aseaniptv2.s3.us-west-1.amazonaws.com/Roku/SERIAL/4114AC001000")
           .to_return(status: 200, body: "", headers: {})
  end

  describe "create" do
    def do_request(**_attributes)
      post :create, format: :jsonapi, activation_requests: { **resource.to_hash, links: { device: device.to_hash } }
    end

    let(:resource) { build :device_activation_request }
    let(:device) { build :roku_device }

    it_behaves_like :create_resource_request, name: :activation_requests, persisted: false do
      let(:respond_with) { { email: resource.email } }
    end

    it "creates a device activation record" do
      expect do
        do_request
      end.to change { Device::Activation.count }.by +1
    end

    it "delivers emails" do
      expect do
        do_request
      end.to change { all_emails.count }.by +2
    end

    describe "email to support" do
      let(:email) { ENV["ROKU_ACTIVATION_EMAIL_RECEIVER"] }

      it "delivers an email to support" do
        do_request
        expect(support_email).to deliver_to email
      end

      it "includes user ip in email" do
        do_request
        expect(support_email).to have_body_text /0\.0\.0\.0|127\.0\.0\.1/
      end

      it "attaches device serial file" do
        do_request
        expect(support_email.attachments).not_to be_empty
      end

      private

      def support_email
        find_email email
      end
    end

    it "delivers an email to customer" do
      email = resource.email

      do_request
      expect(find_email(email)).to deliver_to email
    end

    describe "s3 integration" do
      it "uploads file to s3" do
        expect do
          do_request
        end.to change { count_requests :put, "https://aseaniptv2.s3.us-west-1.amazonaws.com/Roku/SERIAL/#{device.serial_number}" }.by +1
      end
    end

    describe "audit integration" do
      it "updates the ip field" do
        do_request
        expect(Device::Activation.last.ip).to be_present
      end
    end

    describe "black list" do
      let(:black_list_entry) { create :device_black_list_entry }
      let(:device) { build :roku_device, serial_number: black_list_entry.serial_number }

      it "does not create new record" do
        expect do
          do_request
        end.not_to change { Device::Activation.count }
      end
    end
  end
end
