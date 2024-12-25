# frozen_string_literal: true

module WebClient::RenderComponentHelper
  def render(template, *args)
    super
  rescue ActionView::MissingTemplate
    super "#{template}/template", *args
  end
end
