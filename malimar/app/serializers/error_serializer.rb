class ErrorSerializer < ActiveModel::Serializer
  self.root = "errors"
  attributes :status, :title, :detail

  def status
    422
  end

  def title
    "Error"
  end

  def detail
    object.message
  end
end
