require "jwt_token"

describe JwtToken do
  subject { described_class.new "key" }

  describe "encode" do
    it "includes arguments encoded" do
      encoded = subject.encode foo: "bar"
      expect(subject.decode(encoded)).to include foo: "bar"
    end
  end

  describe "when key is not set" do
    subject { described_class.new nil }

    it "raises ArgumentError" do
      expect do
        subject.encode foo: "bar"
      end.to raise_error(ArgumentError)
    end
  end

  describe "when decoding error occurs" do
    it "raises Error" do
      expect do
        subject.decode "token"
      end.to raise_error(described_class::Error)
    end
  end

  it "raises exception when decoded with a different algorithm than it was encoded with" do
    encoder = described_class.new "key", algorithm: "HS512"
    decoder = described_class.new "key", algorithm: "HS256"
    jwt = encoder.encode foo: "bar"

    expect do
      decoder.decode jwt
    end.to raise_error(described_class::Error)
  end

  it "does not raise exception when encoded with the expected algorithm" do
    encoder = described_class.new "key", algorithm: "HS512"
    decoder = described_class.new "key", algorithm: "HS512"
    jwt = encoder.encode foo: "bar"

    expect do
      decoder.decode jwt
    end.not_to raise_error
  end
end
