class Resource::GridsController < ApiController
  caches_action :index, cache_path: ->(_controller) { grids_url(dashboard: params[:dashboard], include: params[:include]) },
                        **action_cache_options

  caches_action :show, cache_path: ->(_controller) { grid_url(id: params[:id], include: params[:include], dashboard: params[:dashboard]) },
                       **action_cache_options

  # Rename to Dashboard show?
  # and use authorize @dashboard
  def index
    load_grids
    render json: @grids
  end

  def show
    load_grid
    authorize_grid

    render_model @grid, except: :href
  end

  private

  def authentication_strategies
    [
      Authentication::GuestStrategy.new(request)
    ]
  end

  def load_grid
    @grid = Resource.find params[:id], feed, loaders: Loader::Grid
  end

  def authorize_grid
    authorize @grid
  end

  def load_grids
    @grids = policy_scope(
      Resource.all(feed, limit: params[:limit], loaders: Loader::Grid),
      policy: Resource::ContainerPolicy
    )
  end

  def dashboard_id
    @dashboard_id ||= params.fetch :dashboard, "Home"
  end

  def feed
    super dashboard_id
  end
end
