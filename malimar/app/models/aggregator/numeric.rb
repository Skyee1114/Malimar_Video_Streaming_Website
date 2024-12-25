module Aggregator
  class Numeric
    def initialize(dataset)
      @dataset = dataset
    end

    def split_by(method, in_delta: 0, threshold_name: "Other", &block)
      data = dataset.sort_by do |object|
        object.public_send(method).to_d
      end.group_by do |object|
        object.public_send(method).to_d
      end

      data = merge_intervals data, in_delta if in_delta
      data = merge_intervals_by_threshold data, threshold_name, &block if block_given?
      data
    end

    def reject_negative(method)
      dataset.reject { |data| data.send(method).to_f < 0 }
    end

    private

    attr_reader :dataset

    def merge_intervals_by_threshold(data, interval_name, &block)
      data.each_with_object(Hash.new([])) do |(interval_value, interval_elements), result|
        if block.call(interval_value)
          result[interval_name] += interval_elements
        else
          result[interval_value] = interval_elements
        end
      end
    end

    def merge_intervals(data, delta)
      last_interval_value = nil
      data.each_with_object({}) do |(interval_value, interval_elements), result|
        if last_interval_value && (interval_value - last_interval_value).abs <= delta
          result[last_interval_value] += interval_elements

        else
          last_interval_value = interval_value
          result[interval_value] = interval_elements

        end
      end
    end
  end
end
