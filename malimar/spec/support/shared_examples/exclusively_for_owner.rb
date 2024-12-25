shared_examples_for :exclusively_for_owner do
  before { do_request }

  describe "when resource not found" do
    def do_request
      super id: "not_found"
    end
    it_behaves_like :forbidden
  end

  describe "when access other user resource" do
    before { sign_in create :user, :registered }
    it_behaves_like :forbidden
  end

  describe "when accessed by guest user" do
    before { sign_out }
    it_behaves_like :forbidden
  end
end
