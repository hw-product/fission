module Fission
  class Worker
    include Celluloid

    attr_accessor :payload

    def initialize
      setup
    end

    def setup
      # Override this in subclasses instead of #initialize
    end

    def process(payload={})
      raise 'This worker has no process!'
    end
  end
end
