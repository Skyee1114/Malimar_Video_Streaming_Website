require "request_data"

describe RequestData do
  subject { described_class.new request }
  let(:request) { double :request, env: {} }

  describe "ip" do
    it "uses request.remote_ip" do
      allow(request).to receive(:remote_ip).and_return "127.0.0.1"
      expect(subject.ip).to eq "127.0.0.1"
    end
  end
end
