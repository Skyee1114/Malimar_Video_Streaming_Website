require "rails_helper"
require "factories/resource/embedded"
require "factories/rewrite_rule"

describe Resource::Embedded::CoverImage do
  include FactoryGirl::Syntax::Methods
  subject { build :cover_image }

  describe "#wide" do
    subject { described_class.new hd: "http://images.malimartv.com/ButsabaTharueaHD.jpg" }

    it "builds from hd image" do
      expect(subject.wide).not_to be_empty
      expect(subject.wide).to include "images.malimartv.com/ButsabaTharueaHD-large.jpg"
    end

    describe "when hd image not set" do
      subject { described_class.new sd: "http://images.malimartv.com/ButsabaTharuea.jpg" }

      it "returns nil" do
        expect(subject.wide).to be_nil
      end
    end

    describe "when hd have some text" do
      subject { described_class.new hd: "i am not an image url" }

      it "returns nil" do
        expect(subject.wide).to be_nil
      end
    end
  end

  describe "rewrite rules" do
    before do
      LocalCache.clear!
    end

    subject { described_class.new hd: "http://malimar.llnwd.net/v1/images/BuddhistGridv2HD.jpg" }

    it "applies rewrite rules" do
      create :rewrite_rule, :image, from: "malimar", to: "rewritten"

      expect(subject.hd).to include "rewritten.llnwd.net"
    end

    it "does not apply non image rules" do
      create :rewrite_rule, :url, from: "example", to: "rewritten"

      expect(subject.hd).not_to include "rewritten"
    end
  end
end
