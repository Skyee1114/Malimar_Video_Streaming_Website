module JsonApiRenderable
  protected

  def render_error(error)
    render json: error, status: :unprocessable_entity, serializer: ErrorSerializer
  end

  def render_model_errors(model)
    render json: model, status: :unprocessable_entity, serializer: RecordErrorSerializer
  end

  def render_model(model, **options)
    if model_invalid?(model)
      return render_model_errors model
    end
    return head :no_content if :no_content == options[:status]

    broadcast :model_rendered, model
    render json: model, options: audit_data.merge(options[:options] || {}), **options
  end

  def render(*args, **options)
    return super unless options.has_key? :json

    respond_to do |format|
      format.jsonapi { super }
      format.json { super }
    end
  end

  private

  def audit_data
    {
      ip: current_ip
    }
  end

  def model_invalid?(model)
    model.respond_to?(:errors) && model.errors.any? || (model.respond_to?(:valid?) && !model.valid?)
    # if model.respond_to?(:errors)
    #   model.errors.any?
    # elsif model.respond_to?(:valid?)
    #   !model.valid?
    # end
  end
end
