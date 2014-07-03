require 'fission'

module Fission

  # Utility modules
  module Utils

    autoload :Github, 'fission/utils/github'
    autoload :Dns, 'fission/utils/dns'
    autoload :NotificationData, 'fission/utils/notification_data'
    autoload :Process, 'fission/utils/process'
    autoload :Inspector, 'fission/utils/inspector'
    autoload :Constants, 'fission/utils/constants'
    autoload :Smash, 'fission/utils/smash'
    autoload :Payload, 'fission/utils/payload'
    autoload :Specs, 'fission/utils/specs'
    autoload :ObjectCounts, 'fission/utils/object_counts'

    # Payload transmission helpers
    module Transmission

      # Transmit provided payload and optional arguments to worker
      #
      # @param worker [String, Symbol] source name to send payload to
      # @param payload [Hash, Object] argument list splatted to transmit
      def transmit(worker, *payload)
        Celluloid::Logger.info "<#{self}> Transmitting payload to worker -> #{worker}"
        src = [worker.to_sym, "fission_#{worker}".to_sym].map do |key|
          Carnivore::Supervisor.supervisor[key]
        end.compact.first
        unless(src)
          abort KeyError.new("Requested worker is not currently registered: #{worker}")
        end
        src.async.transmit(*payload)
      end

    end

    extend Transmission

    # NOTE: This module was extracted to `fission/utils/payload` but
    # we still want to extend here for method access
    extend Payload

    # Unpacking helper for Carnivore::Message items
    module MessageUnpack

      class << self
        # Inject params utility when module is included
        def included(klass)
          klass.send(:include, Carnivore::Utils::Params)
        end
      end

      # Unpack payload from message
      #
      # @param message [Carnivore::Message]
      # @return [Hash]
      def unpack(message)
        if(message[:message])
          case determine_style(message)
          when :sqs
            if(message[:message]['Body'])
              message[:message]['Body'].to_smash
            else
              message[:message].to_smash
            end
          when :http
            begin
              MultiJson.load(message[:message][:body]).to_smash
            rescue MultiJson::DecodeError
              message[:message][:body].to_smash
            end
          when :nsq
            begin
              MultiJson.load(message[:message].message).to_smash
            rescue MultiJson::DecodeError
              message[:message].message.to_smash
            end
          else
            message[:message].to_smash
          end
        else
          message.to_smash
        end
      end

      # Detect message style based on structure
      #
      # @param m [Carnivore::Message]
      # @return [Symbol]
      def determine_style(m)
        begin
          case m[:source].to_s
          when 'Carnivore::Source::Http', 'Carnivore::Source::HttpEndpoint'
            :http
          else
            m[:source].class.to_s.split('::').last.downcase.to_sym
          end
        rescue
          :unknown
        end
      end

    end
  end
end
