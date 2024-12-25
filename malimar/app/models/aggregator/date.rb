module Aggregator
  class Date
    def initialize(dataset)
      @dataset = dataset
    end

    def by_period(period, date_format = nil)
      data = dataset.sort_by do |object|
        object.created_at
      end.group_by do |object|
        start_of_period object.created_at, period
      end

      return data unless date_format

      format_period data, date_format
    end

    private

    attr_reader :dataset

    def start_of_period(date, period)
      date.send "beginning_of_#{period}"
    end

    def format_period(dataset, date_format)
      dataset.map do |date, data|
        [date.strftime(date_format), data]
      end.to_h
    end
  end
end
