require "models/subscription/free"

describe Subscription::Free do
  subject { described_class.new double(:user) }
  describe "#add_time" do
    it "does nothing" do
      expect do
        subject.add_time premium: 12_345
      end.not_to change { subject.expiration_of :premium }
    end
  end

  describe "#has_access_to" do
    it "retuns false" do
      expect(subject).not_to have_access_to :premium
      expect(subject).not_to have_access_to :adult
      expect(subject).not_to have_access_to :foo
    end
  end

  describe "#expiration_of" do
    it "returns start of epoch " do
      expect(subject.expiration_of(:foo)).to eq Time.at(0)
    end
  end
end
