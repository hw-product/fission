require 'carnivore/callback'

module Fission
  # Common validators
  module Validators

    # Redirects payload to code fetcher to provide repository
    class Repository < Fission::Callback

      # Message validity
      #
      # @param message [Carnviore::Message]
      # @return [TrueClass, FalseClass]
      def valid?(message)
        super do |m|
          retrieve(m, :data, :account) && !retrieve(m, :data, :repository)
        end
      end

      # Force message to code_fetcher source
      #
      # @param message [Carnivore::Message]
      def execute(message)
        info "#{message} repository not provided. Forwarding to code fetcher."
        message.confirm!
        transmit(:code_fetcher, unpack(message))
      end

    end
  end
end
