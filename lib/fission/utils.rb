require 'carnivore'

module Fission
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

    module Transmission

      # worker:: worker name
      # payload:: items to `#transmit` on the Carnivore::Source
      # Transmit provided payload and optional arguments to worker
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

    module MessageUnpack

      class << self
        def included(klass)
          klass.send(:include, Carnivore::Utils::Params)
        end
      end

      # message:: Carnivore::Message
      # Unpack the actual payload from the given message regardless of
      # the origin Carnivore::Source
      def unpack(message)
        if(message[:message])
          case determine_style(message)
          when :sqs
            if(message[:message]['Body'])
              Smash.new(message[:message]['Body'])
            else
              message[:message]
            end
          when :http
            begin
              Smash.new(MultiJson.load(message[:message][:body]))
            rescue MultiJson::DecodeError
              message[:message][:body]
            end
          when :nsq
            begin
              Smash.new(MultiJson.load(message[:message].message))
            rescue MultiJson::DecodeError
              message[:message].message
            end
          else
            Smash.new(message[:message])
          end
        else
          message
        end
      end

      # m:: Carnivore::Message
      # Returns "style" of the message based on the structure
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
