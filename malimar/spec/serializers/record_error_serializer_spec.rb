require "rails_helper"
require "factories/user"

describe RecordErrorSerializer do
  let(:serializer) { described_class.new model }
  let(:model) { build_stubbed :user, :invalid }
  let(:root) { "errors" }

  subject { serializer }

  before { expect(model).to be_invalid }

  it "has error title" do
    expect(subject.as_json[root]).to include title: /error/i
  end

  it "includes error detail" do
    expect(subject.as_json[root]).to include detail: /email/
  end

  it "has unprocessable_error status code" do
    expect(subject.as_json[root][:status]).to eq 422
  end

  describe "when object has duplicated errors" do
    it "returns error once in detail" do
      error_field, error_message = model.errors.first
      full_error_message = model.errors.full_messages.first
      model.errors.add error_field, error_message

      detail = subject.as_json[root][:detail]

      expect(detail.scan(full_error_message).count).to eq 1
    end

    it "returns error once in links" do
      error_field, error_message = model.errors.first
      model.errors.add error_field, error_message

      linked_errors = subject.as_json[root][:links]["user"][error_field]
      error_counters = linked_errors.each_with_object(Hash.new(0)) { |word, counts| counts[word] += 1 }

      error_counters.each do |_, counter|
        expect(counter).to eq 1
      end
    end
  end
end
