require 'fission'

module Fission
  module Utils
    # Provide helpers for publishing events
    module Events

      # Send event
      #
      # @param type [String, Symbol] event type
      # @param data [Smash] optional data
      # @return [NilClass]
      def event!(type, data=Smash.new)
        eventers_for(type).each do |endpoint|
          payload = new_payload(
            endpoint, :event => Smash.new(
              :type => type,
              :stamp => Time.now.to_f,
              :data => data
            )
          )
          info "Sending event #{type} to #{endpoint}"
          debug "Sending event data - endpoint: #{endpoint} type: #{type} ID: #{payload[:message_id]} data: #{data.inspect}"
          transmit(endpoint, payload)
        end
      end

      # Find sources registered to receive events of given type
      #
      # @param type [String, Symbol] event type
      # @return [Array<String,Symbol>] source names
      def eventers_for(type)
        app_config.fetch(:eventers, Smash.new).map do |m_type, e_srcs|
          if(File.fnmatch(m_type, type.to_s))
            e_srcs
          end
        end.flatten.compact.map(&:to_sym).uniq
      end

    end
  end
end
