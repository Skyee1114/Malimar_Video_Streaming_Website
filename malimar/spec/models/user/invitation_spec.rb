require "rails_helper"
require "factories/invitation"

describe User::Invitation do
  describe "validity" do
    it "is invalid when invalid email provided" do
      expect(build(:invitation, email: "invalid_email")).not_to be_valid
    end

    it "is invalid when another user with same login exists" do
      user = create :user, :registered, login: "userid@example.com"
      expect(build(:invitation, email: user.login)).not_to be_valid
    end
  end

  describe "id" do
    subject { described_class.new email: user.email }
    let(:user) { build :user, :invited }

    it "returns invited user jwt" do
      tokenizer = subject.send :tokenizer
      loaded_user = tokenizer.load_user subject.id
      expect(loaded_user).to have_attributes(
        id: user.id,
        origin: :invited
      )
    end
  end
end
