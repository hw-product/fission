$VERBOSE=nil

require 'carnivore'
require 'fission'
require 'fission/monkey_patches/jackal_config'
require 'fission/monkey_patches/carnivore_source'
require 'fission/monkey_patches/jackal_callback'

module Fission
  class Runner
    class << self

      # Run fission
      #
      # @param opts [Hash]
      def run!(opts)
        unless(ENV['FISSION_TESTING_MODE'])
          Carnivore.configure!(opts[:config])
          Carnivore::Config.immutable!
        end

        Celluloid.logger.level = Celluloid.logger.class.const_get((opts[:verbosity] || :debug).to_s.upcase)

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
          $stderr.puts 'Fission run failure. Exception encountered.'
          $stderr.puts "#{e.class}: #{e}\n#{e.backtrace.join("\n")}"
          exit -1
        end

      end
    end
  end
end
