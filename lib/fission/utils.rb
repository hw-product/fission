require 'carnivore/utils'

module Fission
  module Utils

    module Transmission

      # Do the right thing!
      def transmit(worker, *payload)
        src = [worker.to_sym, "fission_#{worker}".to_sym].map do |key|
          Celluloid::Actor[key]
        end.compact.first
        unless(src)
          abort KeyError.new("Requested worker is not currently registered: #{worker}")
        end
        src.async.transmit(*payload)
      end

    end

    extend Transmission

    module Payload

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

    extend Payload

    module MessageUnpack

      class << self
        def included(klass)
          klass.send(:include, Carnivore::Utils::Params)
        end
      end

      def unpack(message)
        if(message[:message])
          case determine_style(message)
          when :sqs
            begin
              symbolize_hash(MultiJson.load(message[:message][:body][:message]))
            rescue MultiJson::DecodeError
              message[:message][:body]
            end
          when :http
            begin
              symbolize_hash(MultiJson.load(message[:message][:body]))
            rescue MultiJson::DecodeError
              message[:message][:body]
            end
          else
            message
          end
        else
          message
        end
      end

      def determine_style(m)
        begin
          if(m[:message][:request] && m[:message][:body])
            :http
          elsif(m[:message][:body].is_a?(Hash) && m[:message][:body][:message])
            :sqs
          else
            :unknown
          end
        rescue
          :unknown
        end
      end

    end
  end
end
