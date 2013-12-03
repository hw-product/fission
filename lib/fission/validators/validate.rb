require 'fission/callback'

module Fission
  module Validators

    # Redirects payload to validator to validate payload and set user information
    class Validate < Fission::Callback

      include Fission::Utils::MessageUnpack

      def valid?(message)
        super do |payload|
          !retrieve(payload, :data, :account)
        end
      end

      def execute(message)
        info "#{message} is not validated. Forwarding to validator."
        payload = unpack(message)
        message.confirm!
        transmit(:validator, payload)
      end

    end
  end
end
