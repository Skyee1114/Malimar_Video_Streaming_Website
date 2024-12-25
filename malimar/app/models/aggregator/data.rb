module Aggregator
  class Data
    def initialize(dataset, key: nil)
      @key = key
      @dataset = dataset
    end

    def method_missing(method, *args, &block)
      @dataset = dataset.public_send method, *args, &block
      self
    end

    def by_period(*args, &block)
      add_to_chain date_aggregator.by_period(*args, &block)
    end

    def split_by(*args, &block)
      add_to_chain numeric_aggregator.split_by(*args, &block)
    end

    def reject_negative(*args, &block)
      @dataset = numeric_aggregator.reject_negative(*args, &block)
      self
    end

    def split_by_user_renew
      end_of_period = ::Date.parse key

      transactions_in_period = Transaction
                               .successful
                               .in_period_until(end_of_period)

      customer_ids = transactions_in_period.uniq.pluck(:user_id)

      data = dataset.group_by do |object|
        next :undefined if object.user_id.nil?

        customer_ids.include?(object.user_id) ? :renew
                                              : :new
      end

      add_to_chain data
    end

    def split_by_country
      data = dataset.group_by do |object|
        next :undefined if object.billing_address.blank?

        object.billing_address.country
      end

      add_to_chain data
    end

    def get_total(method, *_args)
      inject(0.to_d) do |total, object|
        total + object.public_send(method).to_d
      end.truncate(2)
    end

    def data
      dataset
    end

    private

    attr_reader :key, :dataset

    def date_aggregator
      Aggregator::Date.new(dataset)
    end

    def numeric_aggregator
      Aggregator::Numeric.new(dataset)
    end

    def add_to_chain(hash)
      data = hash.to_h.map do |key, value|
        [key, self.class.new(value, key: key)]
      end.to_h
      Aggregator::Chain.new data
    end
  end
end
