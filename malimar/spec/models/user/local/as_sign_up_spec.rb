require "rails_helper"
require "factories/user"

describe User::Local::AsSignUp do
  describe "validity" do
    subject { create :user, :as_sign_up }

    it "is invalid when another user with same login exists" do
      subject.save!
      expect(build(:user, :as_sign_up, login: subject.login)).not_to be_valid
    end
  end
end
