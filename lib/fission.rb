require 'celluloid/autostart'

module Fission
  class << self
    attr_accessor :logger
    
    def shutdown
      Celluloid.shutdown
    end

    def boot
      Celluloid.boot
    end
  end
end

require 'fission/version'
require 'fission/config'
require 'fission/supervisor'
