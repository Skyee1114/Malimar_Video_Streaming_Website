require "rails_helper"
require "factories/resource/container"

describe Resource::GridSerializer do
  subject { described_class.new model }

  describe "title" do
    describe "when contains the ROW prefix" do
      let(:model) { build :grid, title: "ROW 3 Movies" }

      it "removes it" do
        expect(subject.title).not_to include "ROW"
        expect(subject.title).to eq "Movies"
      end
    end
  end
end
