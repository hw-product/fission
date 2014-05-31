module Fission
  # Custom exception types
  class Error < StandardError

    # Threshold limit defined has been reached/exceeded
    class ThresholdExceeded < Error; end
    # Requested item is currently locked
    class Locked < Error; end
    # Data translation failed
    class TranslationFailed < Error; end
    # Missing required configuration
    class MissingConfiguration < Error

      # @return [Array<Symbol>, NilClass]
      def missing_path
        @path
      end

      # Define missing configuration path
      #
      # @param args [String, Symbol] argument list style configuration path
      # @return [self]
      def path(*args)
        @path = args.map(&:to_sym)
        self
      end

    end

  end
end
