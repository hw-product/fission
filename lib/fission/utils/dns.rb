module Fission
  module Utils

    # DNS helper methods
    module Dns

      # Provides DNS API if possible
      #
      # @return [Fog::DNS]
      # @raise [ArgumentError]
      # @note fog credentials are required.
      # @config fission.dns.credentials fog arguments
      def dns
        if(creds = Carnivore::Config.get(:fission, :dns, :credentials))
          require 'fog'
          begin
            Fog::DNS.new(creds)
          rescue => e
            abort e
          end
        else
          abort MissingConfiguration.new('No DNS credentials found!')
            .path(:fission, :dns, :credentials)
        end
      end

    end
  end
end
