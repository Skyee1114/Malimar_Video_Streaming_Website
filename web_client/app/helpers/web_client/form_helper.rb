# frozen_string_literal: true

module WebClient::FormHelper
  def form_label(name, label: nil, **options)
    label && content_tag(:label, for: name, class: options[:required] ? "required" : "") do
      label
    end
  end

  def field(name, *args)
    [
      form_label(name, *args),
      form_field(name, *args),
      form_field_error(name)
    ].join.html_safe
  end

  def form_field(name, field: :input, field_type: nil, **options)
    if field == :input
      field_type = "text"
      options[:class] ||= "radius"
    end

    tag field, {
      id: name,
      name: form_name(name),
      type: field_type,
      class: options[:class],
      "ng-model": name
    }.merge(options)
  end

  def form_field_error(name, **_options)
    render "form/field_error", field: name
  end

  def form_name(input_name)
    input_name.to_s.gsub ".", "_"
  end
end
