require 'carnivore/callback'
require 'fission/utils'

module Fission
  class Callback < Carnivore::Callback

    include Fission::Utils::Transmission
    include Fission::Utils::MessageUnpack

    def forward(payload)
      if(payload[:job])
        unless(payload[:job].to_s == name.to_s)
          transmit("fission_#{payload[:job]}".to_sym, payload)
        end
      else
        raise ArgumentError.new('No job type provided in payload!')
      end
    end

  end
end
