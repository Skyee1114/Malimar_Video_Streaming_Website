module EmailImageHelper
  def email_image_tag(image, **options)
    attachments[image] = File.read(Rails.root.join("app/views/#{image}"))
    image_tag attachments[image].url, **options
  end
end
