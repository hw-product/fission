require 'jackal/utils/config'

module Jackal
  module Utils
    module Config

      # @return [Smash] service configuration
      def config
        Carnivore::Config.get(*config_path) ||
          Carnivore::Config.get(:fission, service_name) ||
          Smash.new
      end

    end
  end
end
