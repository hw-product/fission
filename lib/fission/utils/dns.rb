module Fission
  module Utils
    module Dns

      def dns
        if(creds = Carnivore::Config.get(:fission, :dns, :credentials))
          require 'fog'
          begin
            Fog::DNS.new(creds)
          rescue => e
            abort e
          end
        else
          abort ArgumentError.new('No DNS credentials found!')
        end
      end

    end
  end
end
