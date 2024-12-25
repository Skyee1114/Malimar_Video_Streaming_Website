require "rails_helper"
require "factories/susspicious_activity"

describe SusspiciousActivity do
  let(:activity) { build :susspicious_activity }

  it "accepts nil object" do
    activity.object = nil
    expect do
      activity.save
    end.not_to raise_error
  end
end
