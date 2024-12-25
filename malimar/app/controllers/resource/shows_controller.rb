class Resource::ShowsController < ApiController
  caches_action :show, cache_path: ->(_controller) { show_url(id: params[:id], include: params[:include], grid: params[:grid]) },
                       **action_cache_options

  def show
    load_show
    authorize_show

    render_model @show
  end

  private

  def authentication_strategies
    [
      Authentication::GuestStrategy.new(request)
    ]
  end

  def load_show
    @show = Resource.find params.fetch(:id), feed, loaders: Loader::Show
  end

  def authorize_show
    authorize @show
  end

  def feed
    super grid_id
  end

  def grid_id
    @grid_id ||= params.fetch :grid, nil
  end
end
