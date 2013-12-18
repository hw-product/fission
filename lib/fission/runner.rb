$VERBOSE=nil

require 'carnivore'
require 'carnivore/config'

require 'fission'
require 'fission/cli'
require 'fission/setup'
require 'fission/callback'
require 'fission/exceptions'

unless(ENV['FISSION_TESTING_MODE'])
  cli = Fission::Cli.new
  cli.parse_options
  cli.config[:config_path] ||= '/etc/fission/config.json'
  Carnivore::Config.configure(cli.config)
end

Carnivore::Config.auto_symbolize(true)

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
