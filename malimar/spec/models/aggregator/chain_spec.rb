require "models/aggregator/chain"
require "models/aggregator/data"

describe Aggregator::Chain do
  subject { described_class.new dataset }

  let(:group1_dataset) { [1, 2] }
  let(:group2_dataset) do
    {
      group21: group21_aggregator,
      group22: group22_aggregator
    }
  end
  let(:group21_dataset) { [20, 1] }
  let(:group22_dataset) { [20, 2] }

  let(:group1_aggregator) { Aggregator::Data.new group1_dataset }
  let(:group2_aggregator) { described_class.new group2_dataset }
  let(:group21_aggregator) { Aggregator::Data.new group21_dataset }
  let(:group22_aggregator) { Aggregator::Data.new group22_dataset }
  let(:dataset) do
    {
      group1: group1_aggregator,
      group2: group2_aggregator
    }
  end

  it "calls aggregation method for each group" do
    expect(group1_aggregator).to receive(:do_something).once
    expect(group2_aggregator).to receive(:do_something).once.and_call_original
    expect(group21_aggregator).to receive(:do_something).once
    expect(group22_aggregator).to receive(:do_something).once
    subject.do_something
  end

  describe "#data" do
    it "returns aggregated dataset" do
      expect(subject.reduce(:+).data).to eq(
        group1: 3,
        group2: {
          group21: 21,
          group22: 22
        }
      )
    end
  end

  describe "when no aggregation method exists" do
    it "calls the method on dataset itself" do
      expect(group1_dataset).to receive(:reduce).with(:+).once
      subject.reduce(:+)
    end
  end
end
