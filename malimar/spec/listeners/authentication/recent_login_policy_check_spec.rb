require "active_support/core_ext/numeric/time"
require "redis-store-namespace_patch"
require "listeners/authentication/recent_login_policy_check"

describe Authentication::RecentLoginPolicyCheck do
  let(:redis) { Redis::Store::Factory.create "redis://localhost:6379/0/test" }
  subject { described_class.new login_attempts, redis: redis }
  let(:login_attempts) { 1 }
  let(:user) { double :user, id: 1 }

  describe "old token" do
    let(:new_token_payload) { { iat: Time.now } }
    let(:old_token_payload) { { iat: 1.hour.ago } }

    before do
      subject.token_issued user, old_token_payload
      subject.token_issued user, new_token_payload
    end

    it "raises an Error when old token is used" do
      expect do
        subject.user_loaded user, old_token_payload
      end.to raise_error(described_class::Error)
    end

    it "does not raise an Error when new token is used" do
      expect do
        subject.user_loaded user, new_token_payload
      end.not_to raise_error
    end
  end

  describe "several old logins" do
    let(:login_attempts) { 3 }

    it "allows to use n previous tokens" do
      token_payloads = (login_attempts + 1).times.reverse_each.map do |login_attempt|
        { iat: login_attempt.hour.ago }.tap do |payload|
          subject.token_issued user, payload
        end
      end

      expired_token_payload = token_payloads.shift

      token_payloads.each do |payload|
        expect do
          subject.user_loaded user, payload
        end.not_to raise_error
      end

      expect do
        subject.user_loaded user, expired_token_payload
      end.to raise_error(described_class::Error)
    end
  end
end
