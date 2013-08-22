module Fission
  class Supervisor < Celluloid::SupervisionGroup
    include Mixin::ConvertToClassName

    def initialize(*args)
      super
      info 'Supervisor started, adding workers'
      core_services
      initial_spawn
    end

    private

    def supervise_worker(worker, options = {})
      klass = Fission::Worker.const_get(
        convert_to_class_name(worker)
      )
      args = (options[:arguments] || Array.new)
      actor_name = options[:actor_name]
      if(actor_name)
        supervise_as(actor_name, klass, *args)
      else
        supervise(klass, *args)
      end
    end

    def core_services
      debug 'Booting core services'
      supervise_as(:transport, Transport)
    end

    def initial_spawn
      Fission::Config[:workers].each do |worker, options|
        next unless options[:enabled]
        info "Supervising worker: #{worker}"
        supervise_worker(worker, options)
      end
    end
    
  end
end
