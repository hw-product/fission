require 'rubygems'
require 'bundler/setup'
require 'fission'
require 'coveralls'
Coveralls.wear!

logfile = File.open(File.expand_path("../../log/test.log", __FILE__), 'a')
Fission.logger = Logger.new(logfile)

Dir['./spec/support/*.rb'].map {|f| require f }

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  config.before do |example|
    Fission.shutdown
    Fission.boot
  end
end
