require "active_model"
require "validators/email_validator"

describe EmailValidator do
  let(:validator) { described_class }

  it "passes for valid emails" do
    %w[test@example.com freddie.mercury@queen.com].each do |email|
      expect(validator).to be_valid email
    end
  end

  it "disallow invalids" do
    %w[invalid_email alice@1^3.com].each do |email|
      expect(validator).not_to be_valid email
    end
  end
end
