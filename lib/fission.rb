require 'fission/setup'

module Fission
  autoload :Version, 'fission/version'
  autoload :Callback, 'fission/callback'
  autoload :Cli, 'fission/cli'
  autoload :Error, 'fission/exceptions'
  autoload :Utils, 'fission/utils'
  autoload :Transports, 'fission/transports'

  module Validators
    autoload :Repository, 'fission/validators/repository'
    autoload :Validate, 'fission/validators/validate'
  end
end
