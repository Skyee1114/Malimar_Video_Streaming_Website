module GuessDb
  def postgresql?
    adapter == "postgresql"
  end

  def sqlite?
    adapter == "sqlite3"
  end

  def id_params
    postgresql? ? { id: :uuid }
                  : {}
  end

  private

  def adapter
    ActiveRecord::Base.connection.instance_values["config"][:adapter]
  end
end
