require "rails_helper" # TODO: find a way to use ActiveModel::Serializer without Rails
require "serializers/resource/channel_serializer"
require "factories/resource/video"

describe Resource::ChannelSerializer do
  subject { described_class.new model }
  let(:model) { build :channel }

  describe "token" do
    it "adds token to stream_url" do
      expect(PlayableUrl.playable?(subject.stream_url)).to be_truthy
    end
  end
end
