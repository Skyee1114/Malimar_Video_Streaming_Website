require "rails_helper"
require "matrix"
require_relative "shared_examples/permissin_matrix_specs"
require "factories/user"
require "factories/resource/video"

describe RecentlyPlayedPolicy do
  subject { described_class }

  describe "own video" do
    let(:resource) { OpenStruct.new(id: 1, user_id: @user.id) }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,       :registered,  :invited,  :guest,  :admin,  :supervisor,  :agent],
      [:destroy?, true,         false,     false,   true,    true,         true],
    ]
  end

  describe "someone else's video" do
    let(:resource) { OpenStruct.new(id: 1, user_id: "another") }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,       :registered,  :invited,  :guest,  :admin,  :supervisor,  :agent],
      [:destroy?, false,        false,     false,   false,   false,        false],
    ]
  end

  describe "Scope" do
    let(:user) { build :user }

    it "does not include adult content" do
      videos = []
      adult_video = build(:video, :adult)
      videos << build(:video, :premium)
      videos << adult_video
      videos << build(:video, :free)

      resolved_videos = described_class::Scope.new(user, videos).resolve
      expect(resolved_videos).not_to include adult_video
      expect(resolved_videos.count).to eq 2
    end
  end
end
