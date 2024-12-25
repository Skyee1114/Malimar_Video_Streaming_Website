require "rails_helper"

describe User::Mimic do
  it "does not saves to database" do
    expect do
      subject.save!
      subject.save
    end.not_to change { User::Local.count }
  end
end
