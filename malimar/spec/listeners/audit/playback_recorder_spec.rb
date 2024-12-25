require "rails_helper"
require "factories/resource/video"
require "factories/user"

describe Audit::PlaybackRecorder do
  subject { described_class.new user }
  let(:user) { build :user }

  describe "#video_played" do
    let(:video) { build :video, :premium }

    it "adds video to the list" do
      expect_any_instance_of(Audit::RecentlyPlayed).to receive :add
      expect(subject.video_played(video))
    end

    describe "by guest user" do
      let(:user) { build :user, :guest }

      it "skips it" do
        expect_any_instance_of(Audit::RecentlyPlayed).not_to receive :add
        expect(subject.video_played(video))
      end
    end
  end
end
