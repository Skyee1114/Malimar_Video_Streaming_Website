# vars: auth_param
shared_examples_for :auth_strategy do |type:, group: :registered|
  let(:authentication_backend) { "ActionController::HttpAuthentication::#{type}".constantize }
  let(:auth_header) { "#{type} #{auth_param}" }
  let(:user_attributes) { {} }

  describe "when user exists" do
    let(:user) { create :user, group, **user_attributes }
    before { sign_in nil, auth_header: auth_header }

    it "sets user as current" do
      do_request
      expect(subject.send(:current_user)).to eq user
    end
  end

  if %i[registered with_password].include? group
    describe "when user is not found" do
      let(:user) { build_stubbed :user, group, **user_attributes }
      before { sign_in nil, auth_header: auth_header }

      it "requests authentication" do
        expect(authentication_backend).to receive :authentication_request
        do_request
      end

      it "responds with unauthorized" do
        do_request
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe "when invalid credentials provided" do
    before { sign_in nil, auth_header: auth_header }
    let(:auth_param) { "invalid" }

    it "requests authentication" do
      expect(authentication_backend).to receive :authentication_request
      do_request
    end

    it "responds with unauthorized" do
      do_request
      expect(response).to have_http_status :unauthorized
    end
  end

  describe "without credentials" do
    before { sign_out }

    it "signs in as guest" do
      do_request
      expect(subject.send(:current_user)).not_to be_registered
      expect(subject.send(:current_user)).to be_guest
    end
  end
end
