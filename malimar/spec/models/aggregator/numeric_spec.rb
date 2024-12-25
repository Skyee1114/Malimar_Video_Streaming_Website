require "models/aggregator/numeric"

describe Aggregator::Numeric do
  subject { described_class.new dataset }
  let(:small)  { double :small,   amount: 1   }
  let(:medium) { double :medium,  amount: 10  }
  let(:large)  { double :large,   amount: 100 }
  let(:dataset) { [medium, small, large, small, large, large] }

  describe "#split_by" do
    let(:method) { :amount }
    let(:aggregated_data) { subject.split_by method }

    it "returns aggregated data" do
      expect(subject.split_by(method)).to be_a Hash
    end

    it "splits by given method" do
      expect(aggregated_data).to eq(
        1.to_d => [small, small],
        10.to_d => [medium],
        100.to_d => [large, large, large]
      )
    end

    it "sorts by method value" do
      values = aggregated_data.values
      expect(values.first).to include small
      expect(values.last).to include large
    end

    describe "in_delta" do
      let(:aggregated_data) { subject.split_by method, in_delta: 10 }

      it "merges intervals in delta" do
        expect(aggregated_data).to eq(
          1.to_d => [small, small, medium],
          100.to_d => [large, large, large]
        )
      end
    end

    describe "other" do
      let(:aggregated_data) do
        subject.split_by method, threshold_name: "small & medium" do |interval_value|
          interval_value < 100
        end
      end

      it "merges intervals with satisfy given block" do
        expect(aggregated_data).to eq(
          "small & medium" => [small, small, medium],
          100.to_d => [large, large, large]
        )
      end
    end
  end
end
