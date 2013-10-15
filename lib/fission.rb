require 'fission/version'
require 'fission/runner'

require 'fission/callback'

Dir.glob(File.join(File.dirname(__FILE__), 'fission/validators/*.rb')).each do |path|
  require "fission/validators/#{File.basename(path).sub('.rb', '')}"
end
