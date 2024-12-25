require "rails_helper"

describe StateSerializer do
  let(:serializer) { described_class.new model }
  let(:root) { "states" }

  describe "id" do
    describe "US" do
      let(:model) { ["AL", { "name" => "Alabama" }] }

      it "returns state abbr" do
        expect(serializer.id).to eq "AL"
      end
    end

    describe "CA" do
      let(:model) { ["AB", { "name" => "Alberta" }] }

      it "returns state abbr" do
        expect(serializer.id).to eq "AB"
      end
    end

    describe "DE" do
      let(:model) { ["NW", { "name" => "Nordrhein-Westfalen" }] }

      it "returns parametrized capitalized name" do
        expect(serializer.id).to eq "Nordrhein-westfalen"
      end
    end

    describe "CH" do
      let(:model) { ["ZH", { "name" => "Zürich (de)" }] }

      it "replaces special chars" do
        expect(serializer.id).to include "Zurich"
      end

      it "removes data in branches" do
        expect(serializer.id).to eq "Zurich"
      end
    end

    describe "UA" do
      let(:model) { ["68", { "name" => "Khmel'nyts'ka Oblast'" }] }

      it "removes quotes" do
        expect(serializer.id).to eq "Khmelnytska-oblast"
      end
    end

    describe "FR" do
      let(:model) { ["YT", { "name" => "Mayotte (see also separate entry under YT)" }] }

      it "retuns parametrized name" do
        expect(serializer.id).to eq "Mayotte"
      end
    end

    describe "UK" do
      let(:model) { ["45", { "name" => "Carmarthenshire [Sir Gaerfyrddin GB-GFY]" }] }

      it "retuns parametrized name" do
        expect(serializer.id).to eq "Carmarthenshire"
        expect(serializer.name).to eq "Carmarthenshire"
      end
    end
  end
end
