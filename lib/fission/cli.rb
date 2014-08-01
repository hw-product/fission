require 'mixlib/cli'

module Fission
  # CLI interface
  class Cli
    include Mixlib::CLI

    option(:config_path,
      :short => '-c FILE',
      :long => '--config FILE',
      :description => 'Path to configuration file'
    )

    option(:verbosity,
      :short => '-V VERBOSITY',
      :long => '--verbosity VERBOSITY',
      :description => 'Log verbosity (debug info warn error)'
    )

  end
end
