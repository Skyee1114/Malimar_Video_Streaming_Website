require "rails_helper"
require "factories/user"
require "factories/permission"

describe Subscription do
  subject { described_class.new user }
  let(:user) { create :user }

  describe "#add_time" do
    describe "user has permission" do
      let!(:permission) { create :permission, :premium, subject: user, expires_at: 1.day.from_now }

      it "adds time to premium permission" do
        duration = 1.month.to_i

        expect do
          subject.add_time premium: duration
        end.to change { subject.expiration_of :premium }.by duration
      end
    end

    describe "user does not have permission" do
      it "sets permission time to given interval from now" do
        duration = 1.month
        subject.add_time premium: duration
        user.permissions.reload
        expect(subject.expiration_of(:premium)).to be_within(2.seconds).of duration.from_now
      end
    end

    it "reverts both permissins if later one fails" do
      duration = 1.month
      allow(subject).to receive(:add_time_for).with(:admin, any_args).and_call_original
      allow(subject).to receive(:add_time_for).with(:premium, any_args).and_raise

      expect do
        subject.add_time admin: duration, premium: duration
      end.to raise_error(RuntimeError)

      user.permissions.reload
      expect(subject).not_to have_access_to :admin
      expect(subject).not_to have_access_to :premium
    end
  end

  describe "#revoke" do
    describe "user has permission" do
      let!(:permission) { create :permission, :premium, subject: user, expires_at: 1.day.from_now }

      it "expirations permission" do
        expect do
          subject.revoke
        end.to change { subject.has_access_to? :premium }.from(true).to(false)
      end
    end

    describe "user does not have permission" do
      it "does not change access" do
        expect do
          subject.revoke
        end.not_to change { subject.has_access_to? :premium }
      end
    end
  end

  describe "#has_access_to" do
    let!(:permission) { create :permission, :premium, subject: user, expires_at: 1.day.from_now }

    it "retuns true for allowed permissions" do
      expect(subject).to have_access_to :premium
    end

    it "retuns false for not allowed permissions" do
      expect(subject).not_to have_access_to :not_allowed
    end
  end

  describe "#expiration_of" do
    describe "when permission is not expired" do
      let!(:permission) { create :permission, :premium, subject: user, expires_at: 1.day.from_now }

      it "retuns expiration date" do
        expect(subject.expiration_of(:premium)).to be_within(2.seconds).of 1.day.from_now
      end
    end

    describe "when permission is expired" do
      let!(:permission) { create :permission, :premium, subject: user, expires_at: 1.day.ago }

      it "retuns expiration date" do
        expect(subject.expiration_of(:premium)).to be_within(2.seconds).of 1.day.ago
      end
    end

    describe "when permission does not exists" do
      it "returns start of epoch " do
        expect(subject.expiration_of(:premium)).to eq Time.at(0)
      end
    end
  end
end
