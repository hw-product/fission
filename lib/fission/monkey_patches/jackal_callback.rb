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
          Fission.register(*const.split('::').map{|x|snake(x)}.push(klass))
          true
        else
          false
        end
      end

    end

  end
end
