module SerializerSupport
  def render(*args, **options)
    return super unless options.has_key?(:json) && !options[:json].is_a?(String)

    resource = options.fetch :json

    super *args, **options, **included_resources, **serializer_option(resource, **options)
  end

  private

  def included_resources
    { included: params[:include].to_s.split(",") }
  end

  def serializer
    "#{self.class.name.chomp('Controller').singularize}Serializer".constantize
  end

  def serializer_option(resource, **options)
    serializer_type =
      if resource.respond_to? :to_a
        :each_serializer
      else
        :serializer
      end
    return {} if options.has_key? serializer_type

    { serializer_type => serializer }
  end

  def build_serializer(resource, **options)
    build_json_serializer(resource, **included_resources, **serializer_option(resource, **options), **options)
  end
end
