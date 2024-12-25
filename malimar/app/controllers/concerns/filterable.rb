module Filterable
  private

  def filter
    params.fetch(:filter, {})
  end
end
