require "rails_helper"
require "support/wisper"
require "factories/user"
require "factories/payment"
require "factories/gateway"

describe PaymentGateway::AuthorizeNet do
  let(:user) { build_stubbed :user, :registered }
  let(:payment) { build :card_payment }
  let(:gateway) { build :authorize_net_gateway }

  def do_request(**params)
    gateway.execute payment, as: user, **params
  end

  describe "on successful payment" do
    before :context do
      WebMock.stub_request(:post, "https://test.authorize.net/gateway/transact.dll")
             .to_return(body: read_fixture("requests/authorize_net/successful_payment.csv"))
    end

    it "emits a successful_transaction event" do
      expect { do_request }.to broadcast :successful_transaction
      expect { do_request }.not_to broadcast :failed_transaction
    end

    it "creates a transaction" do
      expect do
        do_request
      end.to change { Transaction.count }.by +1
    end

    it "stores audit data" do
      do_request audit: { ip: "192.168.1.1" }
      expect(Transaction.last.ip).to eq "192.168.1.1"
    end
  end

  describe "on failed payment" do
    before :context do
      WebMock.stub_request(:post, "https://test.authorize.net/gateway/transact.dll")
             .to_return(body: read_fixture("requests/authorize_net/duplicated_payment.csv"))
    end

    it "emits failed_transaction event" do
      expect { do_request }.to broadcast :failed_transaction
      expect { do_request }.not_to broadcast :successful_transaction
    end

    it "creates a transaction" do
      expect do
        do_request
      end.to change { Transaction.count }.by +1
    end
  end
end
