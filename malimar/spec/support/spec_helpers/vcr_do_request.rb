module SpecHelpers
  module VcrDoRequest
    def self.[](cassette_name)
      Module.new.tap do |included_module|
        included_module.send :define_method, :do_request do |*args, &block|
          VCR.use_cassette(cassette_name, record: :new_episodes) do
            if defined? super
              super *args, &block
            else
              block.yield
            end
          end
        end
      end
    end
  end
end
