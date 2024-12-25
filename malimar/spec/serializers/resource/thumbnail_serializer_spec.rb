require "rails_helper" # TODO: find a way to use ActiveModel::Serializer without Rails
require "factories/resource/video"
require "factories/resource/container"

describe Resource::ThumbnailSerializer do
  subject { described_class.new model }

  describe "synopsis" do
    describe "for video" do
      let(:model) { build :channel }

      it "it uses the synopsis field" do
        expect(subject.synopsis).to be_present
        expect(subject.synopsis).to eq model.synopsis
      end
    end

    describe "for container" do
      let(:model) { build :show }

      it "it uses the description field" do
        expect(subject.synopsis).to be_present
        expect(subject.synopsis).to eq model.description
      end
    end
  end
end
