require 'fission'

module Fission
  module Utils
    module Specs
      # Helper module for isolating callback testing
      module CallbackLocal

        # @return [Array<Hash>] payloads that have been forwarded
        def forwarded
          @forwarded
        end

        # Store forwarded payloads internally
        #
        # @param payload [Hash]
        def forward(payload)
          @forwarded << payload
        end

        class << self
          # Init data store for internal message capture
          def extended(klass)
            klass.instance_eval do
              @forwarded = []
            end
          end
          alias_method :included, :extended
        end

      end
    end
  end
end
