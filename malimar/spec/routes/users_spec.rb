require "rails_helper"
require "factories/user"

describe "/users", type: :routing do
  describe "/:id.json" do
    let(:user) { create :user }

    it "resolves to user controller" do
      expect(get: "/users/#{user.id}.json").to route_to(
        controller: "user/locals",
        action: "show",
        format: "json",
        id: user.id.to_s
      )
    end
  end
end
