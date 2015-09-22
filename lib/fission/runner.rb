require 'carnivore'
require 'fission'
require 'fission/monkey_patches/jackal_config'
require 'fission/monkey_patches/carnivore_source'
require 'fission/monkey_patches/jackal_callback'

module Fission
  class Runner < Jackal::Loader
    class << self

      # Run fission
      #
      # @param opts [Hash]
      def run!(opts)
        opts = process_opts(opts)
        if(ENV['FISSION_TESTING_MODE'])
          ENV['JACKAL_TESTING_MODE'] = ENV['FISSION_TESTING_MODE']
        end
        configure!(opts)

        begin
          require 'fission/transports'
          # Build all registered transports (sources)
          Fission::Transports.build!
          # Load all configured workers and setup
          Array(Carnivore::Config.get(:fission, :loaders, :workers)).flatten.compact.each do |lib|
            require lib
          end
          Fission.setup!
          # Start the daemon
          Carnivore.start!
        rescue => e
          Carnivore::Logger.warn "Fission shutting down due to received exception: #{e.class}"
          Carnivore::Logger.debug "#{e.class}: #{e}\n#{e.backtrace.join("\n")}"
        end

      end
    end
  end
end
