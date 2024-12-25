require "rails_helper"
require "factories/user"
require "factories/resource/video"

module Audit
  describe RecentlyPlayed do
    include FactoryGirl::Syntax::Methods
    subject { described_class.new user, maximum_size: 2, recently_played_db: recently_played_db, video_db: video_db }

    let(:recently_played_db) { Redis::Store::Factory.create "redis://localhost:6379/0/test_recently_played" }
    let(:video_db) { Redis::Store::Factory.create "redis://localhost:6379/0/test_video_db" }
    before { subject.clear_db }

    let(:user) { double :user, id: 1 }
    let(:video) { build :channel }

    describe "#add" do
      it "adds element to resources" do
        expect do
          subject.add video
        end.to change { subject.resources.count }.by +1
      end

      it "adds element once" do
        subject.add video

        expect do
          subject.add video
        end.not_to change { subject.resources.count }
      end

      it "removes old resources" do
        expect(subject.resources.count).to eq 0

        subject.add build :channel
        subject.add build :channel
        expect do
          subject.add video
        end.not_to change { subject.resources.count }
      end
    end

    describe "#remove" do
      it "removes a resource" do
        subject.add video

        expect do
          subject.remove video
        end.to change { subject.resources.include?(video) }
      end

      it "keeps other resources" do
        another_video = build :channel
        subject.add video
        subject.add another_video

        expect do
          subject.remove video
        end.not_to change { subject.resources.include?(another_video) }
      end
    end

    describe "#resources" do
      before do
        subject.add video
      end

      it "returns video resources" do
        expect(subject.resources).to all be_a Resource::Video
      end

      it "skips unexisting resources" do
        video_db.flushdb
        another_channel = build :channel
        subject.add another_channel
        expect(subject.resources.count).to eq 1
      end
    end
  end
end
