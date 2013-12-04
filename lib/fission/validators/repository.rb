require 'carnivore/callback'

module Fission
  module Validators

    # Redirects payload to code fetcher to provide repository
    class Repository < Fission::Callback

      def valid?(message)
        super do |m|
          retrieve(m, :data, :account) && !retrieve(m, :data, :repository)
        end
      end

      def execute(message)
        info "#{message} repository not provided. Forwarding to code fetcher."
        message.confirm!
        transmit(:code_fetcher, unpack(message))
      end

    end
  end
end
