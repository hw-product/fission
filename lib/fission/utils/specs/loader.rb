require 'fission'
require 'carnivore/config'

# Set fission specific testing mode on
ENV['FISSION_TESTING_MODE'] = 'true'

# Add path to test payloads
Jackal::Utils::Spec.payload_storage(
  File.join(File.dirname(__FILE__), 'payloads')
)

if ARGV.first == 'generate'
  require 'jackal/utils/spec/generator'
else
  require 'fission/utils/specs/helpers'
  require 'jackal/utils/spec/loader'
end
