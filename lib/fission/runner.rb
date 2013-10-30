require 'carnivore'
require 'carnivore/config'

require 'fission'
require 'fission/cli'
require 'fission/setup'
require 'fission/callback'
require 'fission/exceptions'

cli = Fission::Cli.new
cli.parse_options
cli.config[:config_path] ||= '/etc/fission/config.json'

Carnivore::Config.configure(cli.config)
Carnivore::Config.auto_symbolize(true)

begin
  require 'fission/transports'
  Fission::Transports.build!
  Array(Carnivore::Config.get(:fission, :loaders, :workers)).flatten.compact.each do |lib|
    require lib
  end
  Fission.setup!
  Carnivore.start!
rescue => e
  $stderr.puts "FAILED!"
  $stderr.puts "#{e.class}: #{e}\n#{e.backtrace.join("\n")}"
  exit 1
end
