require "rails_helper"
require "factories/user"

describe User::Local::WithPassword do
  subject { create :user, :with_password, password: password }
  let(:password) { "password12345" }

  describe "#has_password?" do
    it "true when password matches" do
      expect(subject).to have_password password
    end

    it "fails when password does not match" do
      expect(subject).not_to have_password "invalid_password"
    end
  end
end
