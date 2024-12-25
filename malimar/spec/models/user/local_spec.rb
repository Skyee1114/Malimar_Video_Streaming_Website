require "rails_helper"
require "support/wisper"
require "factories/user"

describe User::Local do
  subject { create :user }

  describe "validity" do
    subject { build :user }

    it "is invalid when invalid email provided" do
      subject.email = "invalid_email"
      expect(subject).not_to be_valid
    end
  end

  describe "subscription" do
    it "has free subscription by default" do
      subscription = described_class.new.subscription
      expect(subscription).not_to have_access_to :premium
      expect(subscription).not_to have_access_to :adult
    end
  end

  describe ".create" do
    it "emits user_created event" do
      expect do
        create :user
      end.to broadcast :user_created
    end
  end

  describe "model name" do
    it "is user" do
      user = build :user
      expect(user.model_name).to eq "User"
    end
  end
end
