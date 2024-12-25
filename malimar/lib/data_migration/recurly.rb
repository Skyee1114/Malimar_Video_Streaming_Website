require_relative "recurly/user_import"
require_relative "recurly/permission_import"
require_relative "recurly/transaction_import"
require "recurly"

module DataMigration
  class Recurly
    def initialize(logger: { level: Logger::INFO }, threads: 5, recurly:)
      @logger = logger
      @threads_amount = threads
      configure_recurly recurly
    end

    def import_users(**options)
      run UserImport.new **options
    end

    def import_permissions(**options)
      run PermissionImport.new **options
    end

    def import_transactions(**options)
      run TransactionImport.new **options
    end

    private

    attr_reader :logger, :threads_amount

    def run(import)
      processor = Processor::Thread.new(
        import,
        Processor::Observer::Logger.new(logger || { level: ::Logger::DEBUG })
      )

      threads_amount < 2 ? processor.run_successive
                         : processor.run_in_threads(threads_amount)
    end

    def configure_recurly(config)
      ::Recurly.api_key = config.fetch :api_key
      ::Recurly.subdomain = config.fetch :subdomain
    end
  end
end
