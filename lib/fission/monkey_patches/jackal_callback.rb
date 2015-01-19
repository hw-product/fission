require 'jackal/callback'

module Jackal
  class Callback

    class << self

      include Bogo::AnimalStrings

      # Auto register class into fission
      #
      # @param klass [Class]
      # @return [TrueClass, FalseClass]
      def inherited(klass)
        framework, const = klass.name.split('::', 2)
        if(framework == 'Jackal')
          Fission.register(snake(const).sub('::', '_'), klass)
          true
        else
          false
        end
      end

    end

  end
end
