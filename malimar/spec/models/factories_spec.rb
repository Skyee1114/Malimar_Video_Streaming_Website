require "rails_helper"

describe "Factories" do
  FactoryGirl.factories.each do |factory|
    next unless factory.build_class < ActiveRecord::Base

    it "can build valid #{factory.name}" do
      expect(build(factory.name)).to be_valid
    end

    it "can create #{factory.name}" do
      create factory.name
    end
  end
end
