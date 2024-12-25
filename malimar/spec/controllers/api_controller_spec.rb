require "rails_helper"
require "support/shared_examples/auth_strategy"
require "factories/user"

class TestableController < ApiController
  ACTIONS = %i[create update destroy show index].freeze
  before_action :authorize_current_user

  ACTIONS.each do |action|
    define_method(action) { render text: "hello" }
  end

  private

  def authorize_current_user
    authorize Object.new, policy: ResourcePolicy
  end

  class ResourcePolicy < ApplicationPolicy
    ACTIONS.each do |action|
      define_method("#{action}?") { true }
    end
  end
end

describe TestableController do
  after { Rails.application.reload_routes! }

  def do_request(**params)
    create_routes get: :show
    get :show, format: :json, **params
  end

  describe "authentication" do
    describe "bearer" do
      let(:auth_param) { Tokenizer.new(encoder_key: Rails.application.secrets.secret_key_base).generate_token user }
      it_behaves_like :auth_strategy, type: "Bearer"

      describe "with invitation token" do
        it_behaves_like :auth_strategy, type: "Bearer", group: :invited do
          let(:user) { create :user, :invited, **user_attributes }
          before { sign_in nil, auth_header: auth_header }

          it "signs in as invited" do
            do_request
            expect(subject.send(:current_user)).not_to be_registered
            expect(subject.send(:current_user)).to be_invited
          end

          it "uses invited user email address" do
            do_request
            expect(subject.send(:current_user).email).to eq user.email
          end
        end
      end
    end
  end

  describe "authorization" do
    describe "ensure authorization" do
      before { sign_in create :user }
      before(:context) { described_class.skip_before_action :authorize_current_user }
      after(:context) { described_class.before_action :authorize_current_user }

      it "forces to authorize for each action except index" do
        (described_class::ACTIONS - [:index]).each do |action|
          create_routes get: action
          expect do
            get action, format: :json
          end.to raise_error Pundit::AuthorizationNotPerformedError # for index action it raises the policy_scope error
        end
      end

      it "forces to filter elements on index action" do
        create_routes get: :index
        expect do
          get :index, format: :json
        end.to raise_error Pundit::PolicyScopingNotPerformedError
      end
    end

    it "does not blow up for authorized users" do
      user = create :user

      sign_in user

      expect do
        do_request
      end.not_to raise_error
    end
  end

  private

  def create_routes(routes)
    Rails.application.routes.draw do
      routes.each do |method, action|
        send method, "/test_me" => "testable##{action}"
      end
      resources :users
    end
  end
end
