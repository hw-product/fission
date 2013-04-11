require 'rubygems'
require 'bundler/setup'
require 'fission'
require 'coveralls'
Coveralls.wear!

Dir['./spec/support/*.rb'].map {|f| require f }

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  config.before do |example|
    Fission.shutdown
    Fission::Config[:logo] = false
    Fission::Config[:workers] = {}
    Fission::Config[:apis] = []
    Fission.boot
  end
end
