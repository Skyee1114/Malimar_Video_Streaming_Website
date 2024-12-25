class RecoverEmails
  def recover
    emails = []
    File.open("/home/ap/code/malimartv/.elasticbeanstalk/logs/latest/i-edd50926/var/app/containerfiles/logs/sidekiq.log").each do |line|
      emails << extract_email(line) if accept? line
    end
    emails = emails.uniq.compact
    emails.each do |email|
      UserMailers::AccountMailer.new_user_invitation(email).deliver_now
    end
  end

  private

  def accept?(line)
    line.include? "Exceed Sending Limit"
  end

  def extract_email(line)
    group = line.scan(/"deliver_now", "([^"]+)"\]/)[0]
    group[0] if group
  end
end
