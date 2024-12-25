require "models/wide_cover_image"

describe WideCoverImage do
  let(:url) { "https://i.malimarcdn.com/LOOKTHOONGTVNEW2HD.jpg" }
  subject(:command) { described_class }

  describe ".call" do
    subject { command.call(url) }

    it "adds F to the image url" do
      is_expected.to eq "https://i.malimarcdn.com/LOOKTHOONGTVNEW2HDF.jpg"
    end

    context "when image already has F at the end" do
      let(:url) { "https://i.malimarcdn.com/LOOKTHOONGTVNEW2HDF.jpg" }

      it "return original url" do
        is_expected.to eq url
      end
    end

    context "when image url is empty" do
      let(:url) { "" }

      it "returns empty string" do
        is_expected.to eq ""
      end
    end
  end
end
