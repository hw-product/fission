$VERBOSE=nil

require 'carnivore'
require 'fission'
require 'fission/monkey_patches/jackal_config'
require 'fission/monkey_patches/carnivore_source'
require 'fission/monkey_patches/jackal_callback'

unless(ENV['FISSION_TESTING_MODE'])
  cli = Fission::Cli.new
  cli.parse_options
  cli.config[:config_path] ||= '/etc/fission/config.json'
  Carnivore::Config.configure(cli.config)
end

Celluloid.logger.level = Celluloid.logger.class.const_get(
  (Carnivore::Config.get(:verbosity) || :debug).to_s.upcase
)

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
