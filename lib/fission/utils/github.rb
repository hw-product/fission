module Fission
  module Utils
    module Github

      DEFAULT_API_ENDPOINT = 'https://api.github.com/'
      DEFAULT_WEB_ENDPOINT = 'https://github.com/'

      # payload:: Payload
      # Return github API client. Will attempt to discover token from
      # fission configuration. If not found, payload is provided, and
      # data is enabled, the token will be extracted from the data
      # store. Aborts if no token is found.
      def github_client(payload=nil)
        require 'octokit'
        Octokit.api_endpoint = Carnivore::Config.get(:fission, :github, :api_endpoint) ||
          DEFAULT_API_ENDPOINT
        Octokit.web_endpoint = Carnivore::Config.get(:fission, :github, :web_endpoint) ||
          DEFAULT_WEB_ENDPOINT
        token = Carnivore::Config.get(:fission, :github, :access_token)
        if(token.nil? && enabled?(:data))
          account_id = retrieve(payload, :data, :account, :id)
          if(account_id)
            account = Fission::Data::Account[account_id]
            token = account.github_token
          end
        end
        if(token)
          Octokit::Client.new(:access_token => token)
        else
          abort Error.new('Failed to locate access token for github connection')
        end
      end

    end
  end
end
