require 'fission/callback'

module Fission
  module Validators
    class Validate < Fission::Callback

      include Fission::Utils::MessageUnpack

      def valid?(message)
        super do |payload|
          !payload[:data] || !payload[:data][:user]
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
