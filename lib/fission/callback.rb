require 'carnivore/callback'
require 'fission/utils'

module Fission
  class Callback < Carnivore::Callback

    include Fission::Utils::Transmission
    include Fission::Utils::MessageUnpack
    include Fission::Utils::Payload

    def valid?(message)
      m = unpack(message)
      !m[:complete].include?(name)
    end

    def forward(payload)
      if(payload[:job])
        if(payload[:complete].include?(payload[:job]))
          transmit(:finalizer, payload)
        else
          transmit(payload[:job], payload)
        end
      else
        abort ArgumentError.new('No job type provided in payload!')
      end
    end

    def process_manager
      Celluloid::Actor[:process_manager] || abort(NameError.new('No process manager found!'))
    end

    def completed(payload, message=nil)
      payload[:complete].push(name).uniq!
      message.confirm! if message
      forward(payload)
    end

  end
end
