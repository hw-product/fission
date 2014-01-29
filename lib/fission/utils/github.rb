module Fission
  module Utils
    module Github

      # payload:: Payload
      # Return github API client. Will attempt to discover token from
      # fission configuration. If not found, payload is provided, and
      # data is enabled, the token will be extracted from the data
      # store. Aborts if no token is found.
      def github_client(payload=nil)
        require 'octokit'
        # data store based lookup
        token = Carnivore::Config.get(:fission, :github, :access_token)
        if(token.nil? && enabled?(:data))
          account_id = retrieve(payload, :data, :account, :id)
          if(account_id)
            account = Fission::Data::Account[account_id]
            token = account.token
          end
        end
        token ? Octokit::Client.new(:access_token => token) : abort(Error.new('Failed to locate access token for github connection'))
      end

    end
  end
end
