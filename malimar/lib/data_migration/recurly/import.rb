require "processor"

module DataMigration
  class Recurly
    class Import < Processor::Data::NullProcessor
      def initialize(**options); end

      def record_error(_record, error)
        case error
        when ActiveRecord::ConnectionTimeoutError
          sleep rand(3)
          throw :command, :redo

        when ActiveRecord::StatementInvalid
          if $!.message.include? " lock"
            sleep rand(3)
            throw :command, :redo
          end

        when ActiveRecord::RecordInvalid
          if $!.message.include? " taken"
            sleep rand(3)
            throw :command, :redo
          end
        end
      end
    end
  end
end
