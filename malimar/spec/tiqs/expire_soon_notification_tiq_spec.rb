require "rails_helper"
require "tiq_helper"
require "tiqs/expire_soon_notification_tiq"
require "support/spec_helpers/email"
require "factories/user"
require "factories/permission"

describe ExpireSoonNotificatonTiq do
  let(:user) { create :user, :registered }
  include SpecHelpers::Email

  before { reset_redis_db }

  describe "when subscription expires soon" do
    before do
      create :permission, :premium, expires_at: 1.day.from_now, subject: user
    end

    it "sends email to users" do
      expect do
        subject.perform
      end.to change { all_emails.count }.by +1

      expect(last_email_sent).to deliver_to user.email
    end

    describe "and email was already sent before expiration date" do
      before do
        subject.perform
      end

      it "does not send email" do
        expect do
          subject.perform
        end.not_to change { all_emails.count }
      end
    end

    describe "and email was already sent last period" do
      subject { described_class.new period: 1 }
      before do
        subject.perform
      end

      it "sends email to users" do
        expect do
          sleep 1
          subject.perform
        end.to change { all_emails.count }.by +1

        expect(last_email_sent).to deliver_to user.email
      end
    end
  end

  describe "when subscription expires far from now" do
    before do
      create :permission, :premium, expires_at: 1.month.from_now, subject: user
    end

    it "does not send email" do
      expect do
        subject.perform
      end.not_to change { all_emails.count }
    end
  end

  describe "when no subscription present" do
    it "does not send email" do
      expect do
        subject.perform
      end.not_to change { all_emails.count }
    end
  end

  def reset_redis_db
    described_class.redis_connection.flushdb
  end
end
