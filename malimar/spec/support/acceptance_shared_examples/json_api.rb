shared_examples_for :json_api_collection do |name:|
  it "has resource name key", document: false do
    do_request
    expect(json_response).to have_key name
  end

  it "is represented as array", document: false do
    do_request
    expect(json_response[name]).to be_an Array
  end

  it "each element contains the response fields", document: false do
    do_request
    fields = []
    optional_fields = []

    example.metadata.fetch(:response_fields).map do |field_data|
      field = field_data.fetch(:name).to_sym
      fields          << field if field_data[:scope] == name.to_sym
      optional_fields << field if field_data[:required] == false
    end

    json_response[name].each do |resource_hash|
      expect(resource_hash.keys).to match_array fields
      expect(resource_hash).not_to be_any do |field, value|
        (value.nil? || value.empty?) && !optional_fields.include?(field)
      rescue StandardError
        false
      end
    end
  end
end

shared_examples_for :json_api_resource do |name:|
  unless name == :errors
    it "has non error status code", document: false do
      do_request
      expect(status).to be_between 200, 299
    end
  end

  if name == :errors
    it "has 422 status code", document: false do
      do_request
      expect(status).to be 422
    end
  end

  it "has resource name key", document: false do
    do_request
    expect(json_response).to have_key name
  end

  it "is represented as hash", document: false do
    do_request
    expect(json_response[name]).to be_a Hash
  end

  it "contains the response fields", document: false do
    do_request
    fields = []
    optional_fields = []

    example.metadata.fetch(:response_fields).map do |field_data|
      field = field_data.fetch(:name).to_sym
      fields          << field if field_data[:scope] == name.to_sym
      optional_fields << field if field_data[:required] == false
    end

    resource_hash = json_response[name]
    expect(resource_hash.keys).to match_array fields
    expect(resource_hash).not_to be_any do |field, value|
      (value.nil? || value.empty?) && !optional_fields.include?(field)
    rescue StandardError
      false
    end
  end
end

shared_examples_for :json_api_no_content do
  it "has 204 error status code", document: false do
    do_request
    expect(status).to be 204
    expect(response_body).to be_empty
  end
end

shared_examples_for :json_compatible do
  describe "when pure JSON requested" do
    header "Accept", "application/json"

    it "responds with application/json", document: false do
      do_request
      if response_headers["Content-Type"].present?
        expect(response_headers["Content-Type"]).to include("application/json")
      end
    end
  end
end
