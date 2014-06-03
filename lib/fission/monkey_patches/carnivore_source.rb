require 'carnivore'

module Carnivore
  class Source

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

  end
end
