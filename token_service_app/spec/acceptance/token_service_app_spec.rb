require "acceptance_helper"

describe TokenServiceApp do
  describe "playable url" do
    let(:url) { "http://example.com" }
    def do_request(**params)
      get '/', url: url
    end

    describe "Limelight strategy" do
      let(:token_symbols) { 'a-z=0-9&' }
      def do_request(**params)
        header "HOST", "limelighttoken.token.de"
        super
      end

      it "returns an object with url key" do
        do_request
        expect(json_response).to include(
          url: /\A#{ url }\?.+\z/
        )
      end

      it "has the expiration time" do
        do_request
        expect(json_response[:url]).to match /e=[0-9]+/
      end
    end
  end
end
