require "thor"
require "logger"
require_relative "../data_migration/recurly"

module Cli
  class DataMigration < Thor
    class << self
      def start(*)
        load_environment
        super
      end

      def load_environment
        ENV["RAILS_ENV"] ||= "development"
        require File.expand_path("config/environment.rb")
      end
    end

    class_option  :threads,    type: :numeric,  default: 4,          aliases: :t,  desc: "Records to process at once. Lower the value if get a lot of connection errors"
    class_option  :log_level,  type: :string,   default: "INFO",     aliases: :r,  desc: "Logger verbosity", enum: Logger::Severity.constants.map(&:to_s)
    class_option  :subdomain,  type: :string,   default: "malimar",  aliases: :s,  desc: "Recruly subdomain"
    class_option  :api_key,    type: :string,                        aliases: :k,  desc: "Recruly api key"
    # class_option :period,     type: :string,  default: "",         aliases: :p,  desc: 'Period for which users should be loaded. Usage: "Dec 20 2013..Jan 2 2014"'

    desc "import_users_from_recurly [OPTIONS]", "creates local user for each recurly user"
    method_option :reset_password,  type: :boolean, default: false, desc: "Resets password and sends email to each new user"

    def import_users_from_recurly
      data_migration(options).import_users reset_password: options[:reset_password]
    end

    desc "import_permissions_from_recurly [OPTIONS]", "creates permission for each recurly subscription"
    def import_permissions_from_recurly
      data_migration(options).import_permissions
    end

    desc "import_transactions_from_recurly [OPTIONS]", "creates transaction and billing info for recurly transaction"
    def import_transactions_from_recurly
      data_migration(options).import_transactions
    end

    private

    def data_migration(_option)
      log_level = Logger.const_get options[:log_level]

      ::DataMigration::Recurly.new(
        threads: options[:threads] || 8,
        logger: {
          level: log_level
        },
        recurly: {
          subdomain: options[:subdomain],
          api_key: options[:api_key]
        }
      )
    end
  end
end
