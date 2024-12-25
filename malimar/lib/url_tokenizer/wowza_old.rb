require "url_tokenizer"

module UrlTokenizer
  class WowzaOld < Provider
    def call(input_url, **options)
      options = global_options.merge options
      name = input_url.scan(%r{([^/]+)/playlist\.m3u8$}).flatten.first
      "#{input_url}?token=#{generate name, **options}"
    end

    private

    def generate(public_reference, **options)
      token_lifetime = options[:expires_in].to_i

      random_half = generate_random_half Random.new.rand(20)
      token_creation_time = (Time.now.to_i + token_lifetime) * 1000
      token_string = "#{public_reference}-#{token_creation_time}-#{random_half}-#{key}"
      encode = Digest::MD5.hexdigest(token_string)
      token_hash_string = "#{public_reference}-#{token_creation_time}-#{random_half}-#{encode}"

      token_hash_string
    end

    def generate_random_half(chars)
      random_gen = Random.new
      random = ""

      (0..chars).each do |_i|
        random_1 = random_gen.rand(0..1)
        random_2 = random_gen.rand(0..2)
        if random_1 == 0
          random += random_gen.rand("a".ord.."k".ord).chr
        elsif random_1 == 1
          random += random_gen.rand(0..9).to_s
        end

        random = random.downcase if random_2 == 0
      end
      random
    end
  end
end
