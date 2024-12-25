# frozen_string_literal: true

require "rails_helper"
require "factories/user"
require "factories/resource/video"

describe FavoriteVideoList do
  include FactoryGirl::Syntax::Methods
  subject { described_class.new user, video_db: video_db }

  let(:video_db) { Redis::Store::Factory.create "redis://localhost:6379/0/test_video_db" }
  let(:user) { double :user, id: 1 }
  let(:video) { build :channel }

  describe "#add" do
    it "adds video to resources" do
      expect do
        subject.add video
      end.to change { subject.resources.count }.by +1
    end

    context "when resource is already exist" do
      before do
        subject.add video
      end

      it "does nothing" do
        expect do
          subject.add video
        end.not_to raise_error
      end

      it "doesnt duplicate it" do
        expect do
          subject.add video
        end.not_to change { subject.resources.count }
      end
    end
  end

  describe "#remove" do
    before do
      subject.add video
    end

    it "removes a resource" do
      expect do
        subject.remove video
      end.to change { subject.resources.include?(video) }
    end

    it "keeps other resources" do
      another_video = build :channel
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
      expect(subject.resources.count).to eq 0

      another_channel = build :channel
      subject.add another_channel
      expect(subject.resources.count).to eq 1
    end

    describe "sorting" do
      let(:video) { build :channel, id: "abc" }

      it "sorts by updated_at" do
        another_channel = build :channel, id: "zzz"
        subject.add another_channel

        expect(subject.resources.map(&:id)).to eq %w[zzz abc]
      end
    end
  end
end
