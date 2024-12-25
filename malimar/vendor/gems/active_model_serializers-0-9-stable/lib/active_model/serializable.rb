require "active_model/serializable/utils"

module ActiveModel
  module Serializable
    def self.included(base)
      base.extend Utils
    end

    def as_json(options = {})
      instrument("!serialize") do
        if root = options.fetch(:root, json_key)
          hash = { root => serializable_object(options) }
          hash.merge!(serializable_data)
          hash
        else
          serializable_object(options)
        end
      end
    end

    def serializable_object_with_notification(options = {})
      instrument("!serialize") do
        serializable_object(options)
      end
    end

    def serializable_data
      embedded_in_root_associations.tap do |hash|
        hash[meta_key] = meta if respond_to?(:meta) && meta
      end
    end

    def namespace
      get_namespace && Utils._const_get(get_namespace)
    end

    def embedded_in_root_associations
      {}
    end

    private

    def get_namespace
      modules = self.class.name.split("::")
      modules[0..-2].join("::") if modules.size > 1
    end

    def instrument(action, &block)
      payload = instrumentation_keys.each_with_object({ serializer: self.class.name }) do |key, payload|
        payload[:payload] = instance_variable_get(:"@#{key}")
      end
      ActiveSupport::Notifications.instrument("#{action}.active_model_serializers", payload, &block)
    end

    def instrumentation_keys
      %i[object scope root meta_key meta wrap_in_array only except key_format]
    end
  end
end
