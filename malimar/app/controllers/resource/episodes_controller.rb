class Resource::EpisodesController < ApiController
  caches_action :index, cache_path: ->(_controller) { episodes_url(show: params[:show]) },
                        **action_cache_options

  def index
    load_episodes
    render json: @episodes
  end

  def show
    load_episode
    authorize_episode

    subscribe Audit::PlaybackRecorder.new(current_user)
    render_model @episode, serializer: Resource::PlayableEpisodeSerializer, except: :href
  end

  private

  def load_episode
    @episode = Resource.find params.fetch(:id), feed, loaders: Loader::Episode
  end

  def authorize_episode
    authorize @episode
  end

  def load_episodes
    @episodes = policy_scope(
      Resource.all(feed, limit: params[:limit], loaders: Loader::Episode),
      policy: Resource::VideoPolicy
    )
  end

  def feed
    super show_id
  end

  def show_id
    @show_id ||= params.fetch :show, nil
  end
end
