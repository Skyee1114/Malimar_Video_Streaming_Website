class User::InvitationsController < ApiController
  def create
    build_invitation
    authorize_invitation

    deliver @invitation if @invitation.save

    render_model @invitation, status: :created
  end

  private

  def authorize_invitation
    authorize @invitation
  end

  def build_invitation
    @invitation ||= User::Invitation.new invitation_params
  end

  def invitation_params
    params.require(:invitations).permit(:email)
  end

  def deliver(invitation)
    UserMailers::AccountMailer.new_user_invitation(invitation.email).deliver_later
  end
end
