# frozen_string_literal: true

module WebClient::ImageHelper
  def image_tag(*args)
    %!<%= image_tag(*#{args.inspect.gsub('"', "'")}).gsub(/"/, '"') %>!.html_safe
  end
end
