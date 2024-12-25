# frozen_string_literal: true

class FavoriteVideosController < ApiController
  JSON_ROOT = "favorite_videos"

  def index
    load_user
    load_thumbnails
    render json: @thumbnails, each_serializer: Resource::ThumbnailSerializer
  end

  def create
    load_user
    build_favorite_video
    authorize_favorite_video

    location = Resource::ThumbnailSerializer.new(@favorite_video).href if add_favorite_video

    render_model(
      @favorite_video,
      status: :created,
      location: location,
      serializer: Resource::ThumbnailSerializer,
      root: JSON_ROOT
    )
  end

  def destroy
    load_user
    load_favorite_video
    authorize_favorite_video

    remove_favorite_video
    head :no_content
  end

  private

  def load_thumbnails
    @thumbnails = policy_scope(
      video_list.resources,
      policy: FavoriteVideoPolicy, owner: @user
    )
  end

  def remove_favorite_video
    video_list.remove @favorite_video
  end

  def add_favorite_video
    video_list.add @favorite_video
  end

  def build_favorite_video
    @favorite_video = Resource.find(
      link_params.fetch(:video),
      Resource::Feed.new(id: link_params.fetch(:container))
    )
  end

  def authorize_favorite_video
    authorize @favorite_video, policy: FavoriteVideoPolicy, owner: @user
  end

  def load_favorite_video
    @favorite_video = OpenStruct.new(id: params[:id])
  end

  def load_user
    @user = User::Local.find params[:user] || link_params.fetch(:user)
  rescue ActiveRecord::RecordNotFound
    raise Pundit::NotAuthorizedError
  end

  def video_list
    @video_list = FavoriteVideoList.new(@user)
  end

  def link_params
    @link_params ||= params.require(:favorite_videos).require(:links).permit(:user, :container, :video)
  end
end
