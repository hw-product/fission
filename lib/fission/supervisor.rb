module Fission
  class Supervisor
    include Celluloid
    include Celluloid::Logger
    include Mixin::ConvertToClassName

    attr_reader :supervision_group
    
    def initialize
      info 'Spinning up Fission Supervisor'
      @supervision_group = Celluloid::SupervisionGroup.new
      initial_spawn
    end

    private

    def supervise worker, options = {}
      klass = Fission::Worker.const_get(
        convert_to_class_name(worker.to_s)
      )
      args = (options[:arguments] || Array.new)
      actor_name = options[:actor_name]
      if actor_name
        supervision_group.supervise_as(actor_name, klass, *args)
      else
        supervision_group.supervise(klass, *args)
      end
      
    end

    def initial_spawn
      Fission::Config[:workers].select do |worker, options|
        next unless options[:enabled]
        supervise(worker, options) if options[:enabled]
      end
    end

    def shutdown
      root.terminate
    end
  end
end
