class RecordErrorSerializer < ActiveModel::Serializer
  self.root = "errors"
  attributes :status, :title, :detail, :links

  def status
    422
  end

  def title
    "Validation error"
  end

  def detail
    messages = object.errors.full_messages.uniq + associations_with_errors.map do |_name, value|
      value.errors.full_messages
    end

    messages.join(", ").gsub(/^Base /, "")
  end

  def links
    uniq_errors = object.errors.messages.each_with_object({}) do |(field, errors), uniq_errors|
      uniq_errors[field] = errors.uniq
    end

    { error_key(object) => uniq_errors }.tap do |errors|
      associations_with_errors.each do |name, value|
        errors[name] = value.errors.messages
      end
    end
  rescue StandardError
    nil
  end

  private

  def error_key(object)
    object.class.model_name.singular_route_key
  end

  def associations_with_errors
    @associations_with_errors ||=
      Hash[
        object.attributes.select do |_name, value|
          value.respond_to?(:errors) && value.errors.any?
        end
      ]
  end
end
