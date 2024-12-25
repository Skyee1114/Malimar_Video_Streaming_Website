require "rails_helper"
require "support/shared_examples/requests"
require "support/shared_examples/exclusively_for_owner"
require "factories/user"

describe User::LocalsController do
  describe "show" do
    def do_request(**params)
      get :show, {
        format: :json,
        id: resource.id
      }.merge(params)
    end

    let(:resource) { create :user, :registered }
    before { sign_in resource }

    it_behaves_like :get_resource_request, name: :users
    it_behaves_like :exclusively_for_owner
  end

  describe "create" do
    def do_request(**attributes)
      post :create, format: :jsonapi, users: {
        email: resource.email,
        password: resource.password
      }.merge(attributes)
    end

    let(:resource) { build :user, :with_password }

    it_behaves_like :create_resource_request, name: :users do
      let(:respond_with) { { email: resource.email } }
    end

    describe "when subscription parameter is provided" do
      it "is ignored" do
        do_request subscription: { premium_expires_at: 1.month.from_now }
        user = User::Local.where(login: resource.login).take!
        expect(user.subscription).not_to have_access_to :premium
      end
    end
  end

  describe "update" do
    def do_request(**params)
      put :update, {
        format: :jsonapi,
        id: resource.id,
        users: {
          email: resource.email,
          password: resource.password
        }
      }.deep_merge(params)
    end

    let(:resource) { create :user, :with_password }
    before { sign_in resource }

    it_behaves_like :update_resource_request, name: :users
    it_behaves_like :exclusively_for_owner

    describe "when email is invalid" do
      def do_request
        super users: { email: "invalid_email" }
      end

      it_behaves_like :error_resource, name: :errors do
        let(:respond_with) { { detail: /email/i } }
      end
    end

    describe "when password is empty" do
      def do_request(**attributes)
        super users: { password: "" }.merge(attributes)
      end

      it "does not remove user password" do
        expect do
          do_request
        end.not_to change { resource.reload.has_password? resource.password }
        expect(response).to have_http_status :ok
      end

      it "updates other fields" do
        expect do
          do_request email: "new@email.com"
        end.to change { resource.reload.email }.to "new@email.com"
        expect(response).to have_http_status :ok
      end
    end

    it "updates user password" do
      expect do
        do_request users: { password: "abc" }
      end.to change { resource.reload.has_password? "abc" }.from(false).to(true)
      expect(response).to have_http_status :ok
    end
  end
end
