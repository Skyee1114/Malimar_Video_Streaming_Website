require "models/user/types"

describe User::Types do
  describe ".verifier_methods" do
    it "contains all boolead methods" do
      expect(subject.verifier_methods).to match_array %i[guest? local? registered? invited?]
    end
  end
end
