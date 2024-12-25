require_relative "../domain_mailer"
module UserMailers
  class AccountMailer < DomainMailer
    default from: ENV["ACCOUNT_EMAIL_SENDER"]

    def new_user_invitation(invitation_email)
      @invitation = User::Invitation.new email: invitation_email

      mail subject: "Email confirmation from #{domain}", to: @invitation.email
    end

    def new_user_password(password)
      @password = password
      mail subject: "Password reset instructions for #{domain}", to: @password.contact_email
    end
  end
end
