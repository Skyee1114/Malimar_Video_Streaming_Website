require "models/aggregator/date"
require "active_support/time"

describe Aggregator::Date do
  subject { described_class.new dataset }
  let(:today) { double :today, created_at: Date.parse("19/11/2015"), to_s: "today" }
  let(:yesterday) { double :yesterday, created_at: Date.parse("18/11/2015"), to_s: "yesterday" }
  let(:last_year) { double :last_year, created_at: Date.parse("19/11/2014"), to_s: "last_year" }
  let(:dataset) { [today, yesterday, last_year] }

  describe "#by_period" do
    let(:period) { :month }
    let(:aggregated_data) { subject.by_period period }

    it "returns aggregated data" do
      expect(subject.by_period(period)).to be_a Hash
    end

    it "aggregates by given period" do
      values = aggregated_data.values
      expect(values.count).to eq 2
    end

    it "sorts by creation time" do
      values = aggregated_data.values
      expect(values.first).to eq [last_year]
      expect(values.last).to eq [yesterday, today]
    end

    describe "format period date" do
      let(:aggregated_data) { subject.by_period :month, "%b %Y" }
      it "has pediods formatted" do
        expect(aggregated_data.keys).to eq ["Nov 2014", "Nov 2015"]
      end
    end
  end
end
