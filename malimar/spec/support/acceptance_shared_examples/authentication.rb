shared_examples_for :guest_forbidden do
  describe "anonimus user" do
    before { sign_out }

    it "is forbidden to access resource", document: false do
      do_request
      expect(status).to eq 403
    end
  end
end

shared_examples_for :authentication_required do
  include_examples :guest_forbidden

  describe "user with invalid authentication token", document: false do
    before { sign_out }
    before { http_authorization_header token: "invalid_token" }

    it "is unauthorized to access resource" do
      do_request
      expect(status).to eq 401
    end
  end
end

shared_examples_for :publicly_available do
  describe "anonimus user" do
    before { sign_out }

    it "is allowed to access resource", document: false do
      do_request
      expect(status).not_to eq 401
      expect(status).not_to eq 403
    end
  end
end
