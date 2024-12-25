require "models/remote_resource"
require "nokogiri"

describe RemoteResource do
  subject { described_class.new item_document, document: document, source: "http://example.com" }
  let(:document) do
    Nokogiri.XML '<feed>
       <MSUB>FR</MSUB>
       <item>
         <title>Dexter</title>
         <feed type="foobar">http://example.com</feed>
       </item>
     </feed>'
  end
  let(:item_document) { document.at_css "item" }

  describe "#has_field?" do
    it "is true when field present in resource" do
      expect(subject).to have_field :title
    end

    it "is false when field missed in resource" do
      expect(subject).not_to have_field :description
    end
  end

  describe "#feed_type" do
    it "returns feed type attribute" do
      expect(subject.feed_type).to eq "foobar"
    end
  end

  describe "#content_type" do
    it "uses document global MSUB tag" do
      expect(subject.content_type).to eq "FR"
    end

    describe "when item content type provided" do
      let(:document) do
        Nokogiri.XML '<feed>
           <MSUB>FR</MSUB>
           <item>
             <title>Dexter</title>
             <feed type="foobar">http://example.com</feed>
             <MSUB>PR</MSUB>
           </item>
         </feed>'
      end
      it "uses it instead" do
        expect(subject.content_type).to eq "PR"
      end
    end
  end

  describe "#to_h" do
    it "returns a Hash" do
      expect(subject.to_h).to be_a Hash
    end

    it "contains record fields" do
      expect(subject.to_h).to eq(
        "title" => "Dexter",
        "feed" => "http://example.com"
      )
    end
  end
end
