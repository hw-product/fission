require 'carnivore/callback'
require 'fission/utils'

module Fission
  class Callback < Carnivore::Callback

    include Fission::Utils::MessageUnpack

    def forward(payload, message)
      if(payload[:job])
        unless(payload[:job].to_s == name.to_s)
          Celluloid::Actor["fission_#{payload[:job]}"].transmit(payload, message)
        end
      end
    end

  end
end
