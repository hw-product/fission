module Fission
  module Utils
    module NotificationData

      DEFAULT_ORIGIN = {
        :name => 'd2o',
        :dns => 'd2o.hw-ops.com',
        :email => 'd2o@hw-ops.com',
        :application => 'heavywater',
        :http => 'http://www.hw-ops.com',
        :https => 'https://www.hw-ops.com'
      }

      # payload:: Payload
      # state:: state of SHA (pending, success, error, failure)
      # opts:: Options hash (:description, :target_url)
      # Set data in payload for `fission-github-status` component
      def set_github_status(payload, state, opts={})
        payload[:data][:github_status] = {
          :state => state.to_s,
          :description => opts.fetch(:description, "#{Carnivore::Config.get(:fission, :branding, :name) || 'heavywater'} job summary"),
          :target_url => opts.fetch(:target_url, job_url(payload))
        }
      end

      # payload:: Payload
      # opts:: Options hash (:base_url)
      # Return job URL for given payload if available
      def job_url(payload, opts={})
        if(enabled?(:data))
          site = opts.fetch(:base_url, Carnivore::Config.get(:fission, :branding, :https)) || 'http://labs.hw-ops.com'
          begin
            File.join(site, 'jobs', Fission::Data::Job.find_by_message_id(payload[:message_id]).id)
          rescue => e
            debug "Failed to build job URL #{e.class}: #{e}"
            nil
          end
        end
      end

      # Return origin data for notifications
      def origin
        if(branding = Carnivore::Config.get(:fission, :branding))
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
