class Serializer < ActiveModel::Serializer
  include SerializerPolicy

  def self.has_many(*args, **options)
    super *args, **options, embed_namespace: :links
  end

  def self.has_one(*args, **options)
    super *args, **options, embed_namespace: :links
  end

  def initialize(object, included: [], options: {}, **rest)
    @included = included
    @options = options
    super
  end

  private

  attr_reader :included, :options
  def filter(keys)
    keys = super
    return keys if (keys & self.class._associations.keys).empty?

    keys - self.class._associations.keys + included.map(&:to_sym)
  end
end
