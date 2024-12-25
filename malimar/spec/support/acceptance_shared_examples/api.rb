shared_context :api do |authenticate: true|
  header "API-VERSION", "v1"
  header "Accept", "application/vnd.api+json"
  header "Content-Type", "application/vnd.api+json"

  let(:api_user) { create :user }
  around { |spec| as api_user, &spec } if authenticate
end
