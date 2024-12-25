module SpecHelpers
  module Fixtures
    def fixtures_path
      File.expand_path("../../fixtures", File.dirname(__FILE__))
    end

    def read_fixture(path)
      File.read(File.join(fixtures_path, path))
    end
  end
end
