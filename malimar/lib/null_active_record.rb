module NullActiveRecord
  def save
    true
  end

  def save!
    true
  end

  def destroy
    true
  end

  def destroy!
    true
  end

  def reload
    self
  end
end
