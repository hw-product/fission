module Fission
  class Transport
    include Celluloid
    include Celluloid::Logger

    def initialize
      info 'Transport worker starting up, initializing queue'
      @nodes = {}
    end

    trap_exit :on_exit

    def deliver(name, meth, *args, &block)
      @nodes.fetch(name).send(meth, *args, &block)
    rescue
      abort $!
    end

    def fetch(name)
      TransportProxy.new(current_actor, name)
    rescue
      abort $!
    end
    alias_method :[], :fetch
    
    def register(name, actor)
      link actor
      @nodes[name] = actor
      TransportProxy.new(current_actor, name)
    end

    def on_exit(actor, reason)
      @nodes.delete(actor.mailbox)
    end

    class TransportProxy < Celluloid::AbstractProxy
      def initialize(router, name)
        @router = router
        @name = name
      end

      def method_missing(meth, *args, &block)
        if(meth.to_s.end_with?('!'))
          @router.async.deliver(@name, meth.to_s.sub('!', '').to_sym, *args, &block)
        else
          @router.deliver(@name, meth, *args, &block)
        end
      end
    end

  end
end
