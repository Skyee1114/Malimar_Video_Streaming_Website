class RecentlyPlayedController < ApiController
  def index
    load_current_user
    load_thumbnails
    render json: @thumbnails, each_serializer: Resource::ThumbnailSerializer
  end

  def destroy
    load_current_user
    load_recently_played_video
    authorize_recently_played_video

    remove_recently_played_video
    head :no_content
  end

  private

  def load_thumbnails
    @thumbnails = policy_scope(
      Audit::RecentlyPlayed.new(@user).resources,
      policy: RecentlyPlayedPolicy
    )
  end

  def load_recently_played_video
    @recently_played_video = OpenStruct.new(id: params[:id], user_id: @user.id)
  end

  def remove_recently_played_video
    Audit::RecentlyPlayed.new(@user).remove @recently_played_video
  end

  def load_current_user
    @user = current_user.tap do |user|
      raise Pundit::NotAuthorizedError if user.guest?
    end
  end

  def authorize_recently_played_video
    authorize @recently_played_video, policy: RecentlyPlayedPolicy
  end
end
