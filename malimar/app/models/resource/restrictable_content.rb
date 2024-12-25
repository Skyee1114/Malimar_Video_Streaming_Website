module RestictableContent
  TYPES = %i[FR PR AD].freeze

  def self.included(base)
    base.values do
      base.attribute :content_type, Symbol
    end
  end

  def has_adult_content?
    content_type == :AD
  end

  def has_premium_content?
    content_type == :PR
  end

  def has_free_content?
    !has_adult_content? && !has_premium_content?
  end

  def app_content_type
    case content_type
    when :AD then :adult
    when :PR then :premium
    else :free
    end
  end
end
