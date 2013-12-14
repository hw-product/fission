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
        payload = unpack(message)
        message.confirm!
        if(disabled?(:data))
          info 'Currently configured to mock validation. Stubbing with dummy data'
          payload[:data][:account] = {}
          forward(payload)
        else
          info "#{message} is not validated. Forwarding to validator."
          transmit(:validator, payload)
        end
      end

    end
  end
end
