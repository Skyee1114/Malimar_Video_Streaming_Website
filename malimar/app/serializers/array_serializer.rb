class ArraySerializer < ActiveModel::ArraySerializer
  def initialize(object, included: [], **rest)
    @included = included
    super
  end

  def serializer_for(item)
    serializer_class = @each_serializer || Serializer.serializer_for(item, namespace: @namespace) || DefaultSerializer
    serializer_class.new(item, scope: scope, key_format: key_format, context: @context, only: @only, except: @except, polymorphic: @polymorphic, namespace: @namespace,
                               included: included)
  end

  private

  attr_reader :included
end
