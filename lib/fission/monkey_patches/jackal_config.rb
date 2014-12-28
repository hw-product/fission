require 'jackal'

module Jackal
  module Utils
    module Config

      # @return [Smash] service configuration
      def config
        Carnivore::Config.fetch(
          *config_path,
          Carnivore::Config.fetch(
            :fission, service_name, Smash.new
          )
        )
      end

    end
  end
end
