require "rails_helper"

describe "MIME Types", type: :routing do
  include SpecHelpers::WithMimeType

  describe ".json" do
    it "resolves to api controller" do
      expect(get: "/grids.json").to route_to(
        controller: "resource/grids",
        action: "index",
        format: "json"
      )
    end

    describe "when not found" do
      it "is not routable" do
        expect(get: "/lalala.json").not_to be_routable
      end
    end
  end

  describe "HTML" do
    it "resolves to pages controller" do
      expect(get: "/grids").to route_to(
        controller: "pages",
        action: "home",
        any: "grids",
        format: "html"
      )
    end

    describe "when not found" do
      it "resolves to pages controller" do
        expect(get: "/lalala.html").to route_to(
          controller: "pages",
          action: "home",
          any: "lalala",
          format: "html"
        )
      end
    end
  end

  describe "application/json" do
    it "resolves to api controller" do
      with_mime_type "application/json" do
        expect(get: "/grids").to route_to(
          controller: "resource/grids",
          action: "index",
          format: "json"
        )
      end
    end

    describe "with uuid" do
      it "resolves to api controller" do
        with_mime_type "application/json" do
          expect(get: "/devices/905855b9-cfd2-436a-9214-b33395ffb893").to route_to(
            controller: "devices",
            action: "show",
            format: "json",
            id: "905855b9-cfd2-436a-9214-b33395ffb893"
          )
        end
      end
    end

    describe "when not found" do
      it "is not routable" do
        with_mime_type "application/json" do
          expect(get: "/lalala").not_to be_routable
        end
      end
    end
  end

  describe "application/vnd.api+json" do
    it "resolves to api controller" do
      with_mime_type "application/vnd.api+json" do
        expect(get: "/grids").to route_to(
          controller: "resource/grids",
          action: "index",
          format: "json"
        )
      end
    end

    describe "when not found" do
      it "is not routable" do
        with_mime_type "application/vnd.api+json" do
          expect(get: "/lalala").not_to be_routable
        end
      end
    end
  end

  describe "Angular json" do
    it "resolves to api controller" do
      with_mime_type "application/json, text/plain, */*" do
        expect(get: "/grids").to route_to(
          controller: "resource/grids",
          action: "index",
          format: "json"
        )
      end
    end

    describe "when not found" do
      it "is not routable" do
        with_mime_type "application/json, text/plain, */*" do
          expect(get: "/lalala").not_to be_routable
        end
      end
    end
  end

  describe "Angular template" do
    it "resolves to html template" do
      with_mime_type "application/json, text/plain, */*" do
        expect(get: "/grids.html").not_to be_routable
      end
    end

    describe "when not found" do
      it "is not routable" do
        with_mime_type "application/json, text/plain, */*" do
          expect(get: "/lalala.html").not_to be_routable
        end
      end
    end
  end
end
