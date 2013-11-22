require 'carnivore/callback'
require 'fission/utils'

module Fission
  class Callback < Carnivore::Callback

    include Fission::Utils::Transmission
    include Fission::Utils::MessageUnpack

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

    def new_payload(job, payload, *args)
      if(payload.is_a?(String))
        begin
          payload = MultiJson.load(payload)
        rescue MultiJson::DecodeError
          if(args.include?(:json_required))
            raise
          else
            warn 'Failed to convert payload from string to class. Setting as string value'
            debug "Un-JSONable string: #{payload.inspect}"
          end
        end
      end
      {
        :job => job,
        :message_id => Celluloid.uuid,
        :data => payload,
        :complete => []
      }
    end

  end
end
