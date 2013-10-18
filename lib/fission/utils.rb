require 'carnivore/utils'

module Fission
  module Utils

    module Transmission

      # Do the right thing!
      def transmit(worker, *payload)
        src = Celluloid::Actor[worker.to_sym]
        unless(src)
          raise KeyError.new("Requested worker is not currently registered: #{worker}")
        end
        src.async.transmit(*payload)
      end

    end

    extend Transmission

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
