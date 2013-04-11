require 'celluloid/autostart'

module Fission
  class << self
    attr_accessor :logger
    
    def shutdown
      Celluloid.shutdown
    end

    def boot
      Celluloid.boot

      Fission::Supervisor.run!
    end
  end
end

require 'reel'
require 'multi_json'

require 'fission/version'
require 'fission/config'
require 'fission/api'
require 'fission/api_builder'
require 'fission/worker'
require 'fission/workers/webhook'
require 'fission/workers/transport'
require 'fission/mixin/convert_to_class_name'
require 'fission/supervisor'
