require "rails_helper"
require "factories/user"

describe PlayerSelector do
  subject(:selector) { described_class.new viewer, free: free_url, premium: premium_url, adult: adult_url }
  let(:free_url) { "free" }
  let(:premium_url) { "premium" }
  let(:adult_url) { "adult" }

  describe "#url" do
    subject { selector.url }

    shared_examples_for :free_player do
      it "returns free player url" do
        is_expected.to eq free_url
      end

      context "when no free player defined" do
        let(:free_url) { nil }

        it "raises an Exception" do
          expect do
            subject
          end.to raise_exception(described_class::NoPlayerAvailableError)
        end
      end
    end

    shared_examples_for :premium_player do
      it "returns premium player url" do
        is_expected.to eq premium_url
      end

      context "when no premium player defined" do
        let(:premium_url) { nil }

        it "uses free player" do
          is_expected.to eq free_url
        end

        context "when no free player defined" do
          let(:free_url) { nil }

          it "raises an Exception" do
            expect do
              subject
            end.to raise_exception(described_class::NoPlayerAvailableError)
          end
        end
      end
    end

    context "no subscription" do
      let(:viewer) { build :user, :guest }

      it_behaves_like :free_player
    end

    context "expired subscription" do
      let(:viewer) { build :user, :expired }

      it_behaves_like :free_player
    end

    context "premium subscription" do
      let(:viewer) { build :user, :premium }

      it_behaves_like :premium_player
    end

    context "adult subscription" do
      let(:viewer) { build :user, :adult }

      it_behaves_like :premium_player
    end
  end
end
