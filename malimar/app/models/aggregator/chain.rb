module Aggregator
  class Chain
    def initialize(dataset)
      @dataset = dataset
    end

    def method_missing(method, *args, &block)
      @dataset = dataset.map do |key, aggregator|
        [key, aggregator.public_send(method, *args, &block)]
      end.to_h

      self
    end

    def data
      dataset.map do |key, aggregator|
        [key, aggregator.data]
      end.to_h
    end

    private

    attr_reader :dataset
  end
end
