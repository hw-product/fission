require 'fileutils'

module Fission
  module Utils
    module Specs

      # Test files generator
      class Generator < Jackal::Utils::Spec::Generator

        # Create new test instance
        #
        # @return [self]
        def initialize(*_)
          super

          @callback_type   = 'fission'
          @supervisor_name = @service_name
        end

        # Configuration file content
        #
        # @return [String]
        def config_file_content
          <<-TEXT
Configuration.new do
  fission do
    sources do
      #{@service_name}.type 'actor'
      test.type 'spec'
    end

    workers.#{@service_name} 1

    loaders do
      sources ['carnivore-actor']
      workers ['fission-#{@orig_service_name}/#{@module_name}']
    end
  end
end
TEXT
        end
      end

    end
  end
end
