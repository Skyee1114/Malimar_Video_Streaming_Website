module Form
  module LoadLinks
    private

    def load_links(params)
      linked_objects = params[:links]
      return unless linked_objects

      linked_objects.each_with_object(params) do |(attribute, linked_object), links|
        links[attribute.to_sym] ||= load_model attribute, linked_object
      end
    end

    def load_link(attribute, params)
      linked_objects = params[:links]
      return unless linked_objects

      params[attribute] ||= load_model attribute, linked_objects[attribute]
    end

    def load_model(attribute, linked_object)
      attribute_class = attribute_set[attribute].primitive
      return linked_object if linked_object.is_a?(Hash) || !attribute_class.respond_to?(:find)
      return nil if linked_object.blank?

      attribute_class.find linked_object
    end
  end
end
