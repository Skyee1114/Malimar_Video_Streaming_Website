require "rails_helper"
require "matrix"
require_relative "shared_examples/permissin_matrix_specs"
require "factories/user"
require "factories/resource/video"

describe FavoriteVideoPolicy do
  subject { described_class }

  describe "own video" do
    let(:resource) { OpenStruct.new(id: 1) }

    include_examples(:permission_matrix, matrix: Matrix[
      [nil,       :registered,  :invited,  :guest,  :admin,  :supervisor,  :agent],
      [:create?,  true,         false,     false,   true,    true,         true],
      [:destroy?, true,         false,     false,   true,    true,         true],
    ]) { let(:owner) { @user } }
  end

  describe "someone else's video" do
    let(:resource) { OpenStruct.new(id: 1) }

    include_examples(:permission_matrix, matrix: Matrix[
      [nil,       :registered,  :invited,  :guest,  :admin,  :supervisor,  :agent],
      [:create?,  false,        false,     false,   false,   false,        false],
      [:destroy?, false,        false,     false,   false,   false,        false],
    ]) { let(:owner) { build :user } }
  end

  describe "Scope" do
    let(:user) { build :user, id: 100 }
    let(:another_user) { build :user, id: 101 }

    it "does not include other user favorites" do
      videos = []
      another_video = build(:video, :free)
      videos << another_video

      resolved_videos = described_class::Scope.new(user, videos, owner: another_user).resolve
      expect(resolved_videos).not_to include another_video
      expect(resolved_videos.count).to eq 0
    end
  end
end
