require 'fission'

module Fission
  module Validators
    class Validate < Fission::Callback

      include Fission::Utils::MessageUnpack

      def valid?(message)
        !unpack(message).has_key?(:user)
      end

      def execute(message)
        info "#{message} is not validated. Forwarding to validator."
        payload = unpack(message)
        message.confirm!
        transmit(:fission_validator, payload)
      end

    end
  end
end
