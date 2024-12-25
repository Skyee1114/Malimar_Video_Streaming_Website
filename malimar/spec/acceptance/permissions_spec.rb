require "acceptance_helper"
require "factories/user"
require "factories/permission"

resource "Permissions" do
  include_context :api

  module ResponseFields
    def self.included(example)
      example.with_options scope: :permissions do
        response_field :id,          "Permission id"
        response_field :name,        "Permission display name"
        response_field :allow,       "Permission allowance type"
        response_field :active,      "Permission boolean active/expired status"
        response_field :expires_at,  "Permission expiration date"
      end
    end
  end

  get "/permissions?user=:user_id" do
    let!(:permissions) do
      [
        create(:permission, :premium, subject: api_user)
      ]
    end

    parameter :user_id, "User id"
    let(:user_id) { api_user.id }

    response_field :permissions, "Permissions of the given user"
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_collection, name: :permissions
    example_request "Get a list of permissions for given user" do
      permissions.each do |permission|
        expect(json_response[:permissions]).to include include(
          id: permission.id
        )
      end
    end
  end

  get "/permissions?user=:user_id&filter[active]=true" do
    let!(:premium_permission) { create(:permission, :premium, subject: api_user) }

    parameter :user_id, "User id"
    let(:user_id) { api_user.id }

    response_field :permissions, "Permissions of the given user"
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_collection, name: :permissions

    example_request "Get a list of active user permissions" do
      expect(json_response[:permissions].count).to eq 1
      expect(json_response[:permissions].first.fetch(:id)).to eq premium_permission.id
    end
  end
end
