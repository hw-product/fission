require 'carnivore'
require 'carnivore/config'
require 'fission/cli'

cli = Fission::Cli.new
cli.parse_options
cli.config[:config_path] ||= '/etc/fission/config.json'

Carnivore::Config.configure(cli.config)

begin
  require 'fission/transports'
  Array(Carnivore::Config.get(:fission, :load)).flatten.compact.each do |lib|
    require lib
  end
  Carnivore.start!
rescue => e
  $stderr.puts "FAILED!"
  $stderr.puts "#{e.class}: #{e}\n#{e.backtrace.join("\n")}"
  exit 1
end
