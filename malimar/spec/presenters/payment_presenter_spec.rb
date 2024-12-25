require "rails_helper"
require "formatters/phone_formatter"

describe PaymentPresenter do
  describe "phone" do
    subject { described_class.new transaction, subscription: subscription }
    let(:subscription) { double :subscription }
    let(:transaction) { double :transaction, billing_address: billing_address }
    let(:billing_address) { double :billing_address, phone: phone, country: country }
    let(:phone) { "8175289950" }

    shared_examples_for :us_phone_number do
      it "formats the number according to US rules" do
        expect_any_instance_of(PhoneFormatter).to receive(:to_us_format)
        subject.phone
      end
    end

    describe "for US" do
      let(:country) { "US" }
      it_behaves_like :us_phone_number
    end

    describe "for CA" do
      let(:country) { "CA" }
      it_behaves_like :us_phone_number
    end

    describe "for other countries" do
      let(:country) { "UA" }

      it "returns the same number" do
        expect(subject.phone).to eq "8175289950"
      end
    end
  end
end
