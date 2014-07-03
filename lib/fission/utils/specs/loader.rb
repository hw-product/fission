require 'fission'
require 'carnivore/config'
require 'fission/utils/specs/helpers'

# Set fission specific testing mode on
ENV['FISSION_TESTING_MODE'] = 'true'

# Add path to test payloads
Jackal::Utils::Spec.payload_storage(
  File.join(File.dirname(__FILE__), 'payloads')
)

require 'jackal/utils/spec/loader'
