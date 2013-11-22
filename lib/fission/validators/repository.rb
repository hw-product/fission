require 'carnivore/callback'

module Fission
  module Validators
    class Repository < Fission::Callback

      def valid?(message)
        super do |m|
          m[:data][:user] && !m[:data][:repository]
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
