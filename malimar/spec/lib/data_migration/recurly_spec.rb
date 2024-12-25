require "rails_helper"
require "support/vcr"
require "data_migration/recurly"
require "factories/user"
require "factories/transaction"

describe DataMigration::Recurly, migration: true do
  include SpecHelpers::Email
  subject { described_class.new logger: logger, threads: 1, recurly: recurly_config }
  let(:logger) { Logger.new "/dev/null" }
  # let(:logger) { Logger.new STDOUT }

  let(:recurly_config) do
    { api_key: ENV["RECURLY_API_KEY"],
      subdomain: ENV["RECURLY_SUBDOMAIN"] }
  end

  describe "import_users" do
    let(:total_users) { 47 }

    it "creates local users" do
      expect do
        VCR.use_cassette("data_migration/recurly_users", record: :new_episodes) do
          subject.import_users
        end
      end.to change { User::Local.count }.by total_users
    end

    it "resets password for new users" do
      expect do
        VCR.use_cassette("data_migration/recurly_users", record: :new_episodes) do
          subject.import_users reset_password: true
        end
      end.to change { all_emails.count }.by total_users
    end

    describe "when user exists" do
      let!(:user) { create :user, email: "alex@crasome.com" }
      it "does not create new account" do
        expect do
          VCR.use_cassette("data_migration/recurly_users", record: :new_episodes) do
            subject.import_users
          end
        end.to change { User::Local.count }.by total_users - 1
      end

      it "does not reset password" do
        expect do
          VCR.use_cassette("data_migration/recurly_users", record: :new_episodes) do
            subject.import_users reset_password: true
          end
        end.to change { all_emails.count }.by total_users - 1
      end
    end
  end

  describe "import_permissions" do
    let(:subscriptions_count) { 15 }
    let(:permissions_count) { subscriptions_count }

    it "creates local permissions" do
      expect do
        VCR.use_cassette("data_migration/recurly_users", record: :new_episodes) do
          subject.import_permissions
        end
      end.to change { Permission.count }.by permissions_count
    end

    describe "when user have one of the premissions" do
      let!(:user) { create :user, email: "alex@crasome.com" }
      let!(:permission) { create :permission, :premium, subject: user }

      it "does not create existing subscription" do
        expect do
          VCR.use_cassette("data_migration/recurly_users", record: :new_episodes) do
            subject.import_permissions
          end
        end.to change { Permission.count }.by permissions_count - 1
      end
    end
  end

  describe "import_transactions" do
    let(:transactions_count) { 91 }
    let(:billing_info_count) { 34 }

    it "creates local transactions" do
      expect do
        VCR.use_cassette("data_migration/recurly_users", record: :new_episodes) do
          subject.import_transactions
        end
      end.to change { Transaction.count }.by transactions_count
    end

    it "creates billing info" do
      expect do
        VCR.use_cassette("data_migration/recurly_users", record: :new_episodes) do
          subject.import_transactions
        end
      end.to change { BillingAddress.count }.by billing_info_count
    end
  end
end
