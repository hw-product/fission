module Fission
  module Utils
    # Reusable constants for components to share
    module Constants

      # define substrings to signal prerelease
      PRERELEASE = [
        'alpha',
        'beta',
        'pre',
        'prerelease'
      ]

      # Check if string matches any prerelease items
      #
      # @param string [String]
      # @return [TrueClass, FalseClass]
      def prerelease?(string)
        !!PRERELEASE.detect do |item|
          string.match(/\w#{Regexp.escape(item)}(\w|$)/)
        end
      end

    end
  end
end
