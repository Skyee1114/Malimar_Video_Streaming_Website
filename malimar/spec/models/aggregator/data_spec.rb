require "models/aggregator/data"
require "active_support/time"

describe Aggregator::Data do
  subject { described_class.new dataset }
  let(:dataset) { [1, 2, 3] }

  describe "#by_period" do
    let(:period) { :month }
    it "delegates to date_aggregator" do
      expect_any_instance_of(Aggregator::Date).to receive(:by_period).once
      subject.by_period period
    end

    it "returns chain aggregator" do
      allow_any_instance_of(Aggregator::Date).to receive(:by_period)
      expect(subject.by_period(period)).to be_a Aggregator::Chain
    end
  end
end
