Mime::Type.register "application/vnd.api+json", :jsonapi
ActionDispatch::ParamsParser::DEFAULT_PARSERS[Mime::JSONAPI] = ->(body) { JSON.parse body }
