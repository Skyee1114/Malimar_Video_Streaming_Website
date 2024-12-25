class Resource::ChannelsController < ApiController
  def show
    load_channel
    authorize_channel

    subscribe Audit::PlaybackRecorder.new(current_user)
    render_model @channel
  end

  private

  def load_channel
    @channel = Resource.find params.fetch(:id), feeds, loaders: Loader::Channel
  end

  def authorize_channel
    authorize @channel
  end

  def feeds
    return channel_feeds if grid_id.blank?

    feed grid_id
  end

  def channel_feeds
    %w[
      LiveTV_Free_CF
      LiveTV_Premium_CF
      LiveTV_PremiumHD_CF
    ].map do |grid_id|
      feed grid_id
    end
  end

  def grid_id
    @grid_id ||= params.fetch :grid, nil
  end
end
