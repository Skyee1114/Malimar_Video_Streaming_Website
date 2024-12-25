require "models/authentication"

describe Authentication do
  subject { Class.new.extend Authentication }

  describe "#authenticate_using strategy" do
    describe "on successfull authentication" do
      let(:user) { double :user }
      let(:strategy) { double :strategy, authenticate: user, name: :strategy }

      it "returns user" do
        expect(subject.authenticate_using(strategy)).to eq user
      end
    end
  end
end
