require 'fission'

module Fission
  module Utils
    module Specs
      module CallbackLocal

        def forwarded
          @forwarded
        end

        def forward(payload)
          @forwarded << payload
        end

        class << self
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
