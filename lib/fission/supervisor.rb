module Fission
  class Supervisor
    include Celluloid
    include Logger

    attr_accessor :workers

    trap_exit :respawn

    def initialize
      @workers = {}
      initial_spawn
    end

    def create_worker(klass)
      obj = klass.new
      self.link obj
      @workers[klass] ||= []
      @workers[klass] << obj
      info "New worker spawned: #{klass}"
      true
    end

    def respawn(actor, reason)
      warn "Dead actor detected: #{actor.inspect} - Reason: #{reason}"
      @workers[klass].delete(obj)
      create_worker(actor.class)
    end

    private

    def initial_spawn
      Config[:workers].each do |worker, count|
        count = count.to_i
        if(count > 0)
          klass = Worker.const_get(worker)
          count.times do
            create_worker(worker)
          end
        end
      end
    end
  end
end
