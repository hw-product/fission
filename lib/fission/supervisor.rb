module Fission
  class Supervisor < Celluloid::SupervisionGroup
    include Mixin::ConvertToClassName

    def initialize
      super
      info 'Supervisor starting up, spawning workers'
      initial_spawn
    end

    private

    def supervise_worker worker, options = {}
      klass = Fission::Worker.const_get(
        convert_to_class_name(worker.to_s)
      )
      args = (options[:arguments] || Array.new)
      actor_name = options[:actor_name]
      if actor_name
        supervise_as(actor_name, klass, *args)
      else
        supervise(klass, *args)
      end
      
    end

    def initial_spawn
      Fission::Config[:workers].each do |worker, options|
        next unless options[:enabled]
        info "Supervising worker #{worker}"
        supervise_worker(worker, options) if options[:enabled]
      end
    end
    
  end
end
