require 'mixlib/cli'

module Fission
  class Cli
    include Mixlib::CLI

    option(:config_path,
      :short => '-c FILE',
      :long => '--config FILE',
      :description => 'Path to configuration file'
    )

  end
end
