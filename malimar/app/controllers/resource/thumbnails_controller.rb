class Resource::ThumbnailsController < ApiController
  caches_action :index, cache_path: ->(_controller) { thumbnails_url(container: params[:container], limit: params[:limit]) },
                        **action_cache_options

  def index
    load_thumbnails
    render json: @thumbnails
  end

  private

  def authentication_strategies
    [
      Authentication::GuestStrategy.new(request)
    ]
  end

  def load_thumbnails
    @thumbnails = policy_scope(
      Resource.all(feed, limit: params[:limit]),
      policy: Resource::ThumbnailsPolicy
    )
  end

  def feed
    super container_id
  end

  def container_id
    @container_id ||= params.fetch :container, nil
  end
end
