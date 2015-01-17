require 'carnivore'

module Carnivore
  class Source

    include Fission::Utils::MessageUnpack

    # Error processor for messages matching multiple callbacks
    #
    # @param message [Carnivore::Message]
    # @return [TrueClass]
    def multiple_callback(message)
      warn "Processing message matching multiple callbacks when feature is disabled #{message}"
      callback_supervisor[callback_name(callbacks.first)].async.failed(
        unpack(message), message, 'Multiple callbacks matched but multiple callbacks are disabled'
      )
      true
    end

    # @return [TrueClass, FalseClass] disable multiple callback matching by default
    def multiple_callback?
      original_args.fetch(:allow_multiple_matches, false)
    end

    # Orphan callback for message with no matching callbacks
    #
    # @param message [Carnivore::Message]
    # @return [TrueClass]
    # @note this callback will only act if the payload is being
    #   routed via the router. If the job is still set as router
    #   and the route is still populated, this will inject completed
    #   and forward back to the router (allows no-op jobs in route)
    def orphan_callback(message)
      payload = unpack(message)
      if(payload[:job] == 'router')
        job_stub = payload.fetch(:data, :router, :route, []).first
        if(job_stub)
          warn "Stubbing job `(#{job_stub})` for message `(#{message})` due to callback match failure"
          payload[:complete].push(job_stub).uniq!
        end
      end
      message.confirm!
      unless(payload[:frozen])
        warn "Forcing orphaned message back to router! (#{message})"
        begin
          Fission::Utils.transmit(
            Carnivore::Config.fetch(
              :fission, :core, :orphan, :router
            )
          )
        rescue => e
          error "Failed to re-route orphaned message! (#{message})"
        end
      else
        warn "Orphaned message is frozen. Dropping! (#{message})"
      end
    end

  end
end
