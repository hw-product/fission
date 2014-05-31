module Fission
  module Utils
    # Github helper methods
    module Github

      # Default github api endpoint
      DEFAULT_API_ENDPOINT = 'https://api.github.com/'
      # Default github web endpoint
      DEFAULT_WEB_ENDPOINT = 'https://github.com/'

      # Build github API client. Defaults to access token provided via
      # configuration.
      #
      # @param custom_token [String] optional token
      # @return [Octokit::Client]
      # @config fission.github.api_endpoint custom github api endpoint
      # @config fission.github.web_endpoint custom github web endpoint
      # @config fission.github.access_token access token for client
      def github_client(custom_token=nil)
        require 'octokit'
        Octokit.api_endpoint = Carnivore::Config.get(:fission, :github, :api_endpoint) ||
          DEFAULT_API_ENDPOINT
        Octokit.web_endpoint = Carnivore::Config.get(:fission, :github, :web_endpoint) ||
          DEFAULT_WEB_ENDPOINT
        token = Carnivore::Config.get(:fission, :github, :access_token) || custom_token
        if(token)
          Octokit::Client.new(:access_token => token)
        else
          abort MissingConfiguration.new('No github access token available').
            path(:fission, :github, :access_token)
        end
      end

    end
  end
end
