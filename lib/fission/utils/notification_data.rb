module Fission
  module Utils
    # Notification helper methods
    module NotificationData

      # Default information for origin of messages
      # @config fission.branding overloads for origin data
      DEFAULT_ORIGIN = {
        :name => 'd2o',
        :dns => 'd2o.hw-ops.com',
        :email => 'd2o@hw-ops.com',
        :application => 'heavywater',
        :http => 'http://www.hw-ops.com',
        :https => 'https://www.hw-ops.com'
      }

      # Set data in payload for consumption by fission-github-status
      #
      # @param payload [Hash]
      # @param state [String, Symbol] pending, success, error, failure
      # @param opts [Hash]
      # @option opts [String] :description description of status
      # @option opts [String] :target_url URL associated to status
      # @return [TrueClass]
      def set_github_status(payload, state, opts={})
        payload.set(:data, :github_status,
          Smash.new(
            :state => state.to_s,
            :description => opts.fetch(:description,
              "#{Carnivore::Config.get(:fission, :branding, :name) || 'heavywater'} job summary"),
            :target_url => opts.fetch(:target_url, job_url(payload))
          )
        )
        true
      end

      # Generate job URL for payload if possible
      #
      # @param payload [Hash]
      # @param opts [Hash]
      # @option opts [String] :base_url
      # @return [String, NilClass]
      def job_url(payload, opts={})
        if(enabled?(:data))
          site = opts.fetch(:base_url,
            Carnivore::Config.get(:fission, :branding, :https)
          ) || 'http://labs.hw-ops.com'
          begin
            File.join(site, 'jobs', payload[:message_id])
          rescue => e
            debug "Failed to build job URL: #{e}"
            debug "#{e.class}: #{e}\n#{e.backtrace.join("\n")}"
            nil
          end
        end
      end

      # Return origin data for notifications
      #
      # @param brand [String, Symbol] branding key
      # @return [Smash]
      def origin(brand = nil)
        branding = [brand, :default].compact.detect do |key|
          Carnivore::Config.get(:fission, :branding, key)
        end
        if(branding)
          DEFAULT_ORIGIN.merge(
            Hash[*branding.map{|k,v| [k.to_sym, v]}.flatten]
          )
        else
          DEFAULT_ORIGIN
        end
      end

    end
  end
end
