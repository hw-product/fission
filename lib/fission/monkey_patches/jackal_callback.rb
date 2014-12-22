require 'jakcal'

module Jackal
  class Callback

    class << self

      # Auto register class into fission
      #
      # @param klass [Class]
      # @return [TrueClass, FalseClass]
      def inherited(klass)
        framework, const = klass.name.split('::', 2)
        if(framework == 'Jackal')
          const.map! do |string|
            string.gsub(/(?<![A-Z])([A-Z])/, '_\1').sub(/^_/, '').downcase.to_sym
          end
          Fission.register(*const.push(klass))
          true
        else
          false
        end
      end

    end

  end
end
