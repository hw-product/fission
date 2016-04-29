require 'fission'

module Fission

  # Utility modules
  module Utils

    autoload :Cipher, 'fission/utils/cipher'
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
    autoload :Events, 'fission/utils/events'
    autoload :RemoteProcess, 'fission/utils/remote_process'
    autoload :RemoteProcessing, 'fission/utils/remote_process'

    # Payload transmission helpers
    module Transmission

      # Transmit provided payload and optional arguments to worker
      #
      # @param worker [String, Symbol] source name to send payload to
      # @param payload [Hash, Object] argument list splatted to transmit
      def transmit(worker, *payload)
        if(payload.first.is_a?(Hash))
          msg_id = payload.first[:message_id]
        end
        Carnivore::Logger.info "<#{self}> Transmitting payload to worker -> #{worker} (Message ID: #{msg_id || '<unknown>'})"
        src = [worker.to_sym, "fission_#{worker}".to_sym].map do |key|
          Carnivore::Supervisor.supervisor[key]
        end.compact.first
        unless(src)
          abort KeyError.new("Requested worker is not currently registered: #{worker}")
        end
        src.async(:locked).transmit(*payload)
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
        result = if(message[:content])
                   message[:content]
                 else
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
        # Support receiving jobs from jackal services
        unless(result[:message_id])
          stub_payload = new_payload(result[:name], {})
          stub_payload[:message_id] = result[:id]
          result = stub_payload.deep_merge(result)
        end
        if(respond_to?(:formatters) && respond_to?(:service_name))
          formatters.each do |formatter|
            next if result.fetch(:formatters, []).include?(formatter.class.name)
            begin
              if(service_name.to_sym == formatter.destination)
                debug "Service matched formatter for pre-format! (<#{formatter.class}> - #{message})"
                s_checksum = result.checksum
                formatter.format(result)
                unless(s_checksum == result.checksum)
                  info "Pre-formatter modified payload and will not be applied again after callback completion (<#{formatter.class}> - #{message})"
                  result[:formatters].push(formatter.class.name)
                end
              end
            rescue => e
              error "Formatter failed <#{formatter.source}:#{formatter.destination}> #{e.class}: #{e}"
            end
          end
        end
        result
      end

      # Detect message style based on structure
      #
      # @param m [Carnivore::Message]
      # @return [Symbol]
      def determine_style(m)
        begin
          case m[:source].to_s
          when m.start_with?('Carnivore::Source::Http')
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
