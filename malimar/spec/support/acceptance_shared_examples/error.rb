shared_context :error do
  response_field :errors,  "Errors object"
  response_field :title,   "Summary of the problem",                           scope: :errors
  response_field :detail,  "Explanation of the problem",                       scope: :errors
  response_field :status,  "The HTTP status code applicable to this problem",  scope: :errors
  response_field :links,   "",                                                 scope: :errors

  it_behaves_like :json_compatible
  it_behaves_like :json_api_resource, name: :errors
  it "has error status code", document: false do
    do_request
    expect(status).to eq 422
  end
end
