require 'hashie'

module Fission
  module Utils
    class Smash < Hash
      include Hashie::Extensions::IndifferentAccess
      include Hashie::Extensions::DeepMerge
      include Hashie::Extensions::Coercion

      coerce_value Hash, Smash

      def initialize(*args)
        base = nil
        if(args.first.is_a?(::Hash))
          base = args.shift
        end
        super *args
        if(base)
          self.replace(base)
        end
      end

      def retrieve(*args)
        args.inject(self) do |memo, key|
          if(memo.is_a?(Hash))
            memo.to_smash[key]
          else
            nil
          end
        end
      end

      def fetch(*args)
        default_value = args.pop
        retrieve || default_value
      end

      def set(*args)
        unless(args.size > 1)
          raise ArgumentError.new 'Set requires at least one key and a value'
        end
        value = args.pop
        set_key = args.pop
        leaf = args.inject(self) do |memo, key|
          unless(memo[key].is_a?(Hash))
            memo[key] = Smash.new
          end
          memo[key]
        end
        leaf[key] = value
        value
      end

    end
  end

  class Hash
    def to_smash
      Fission::Smash.new.replace(self)
    end
    alias_method :hulk_smash, :to_smash
  end
end

Smash = Fission::Utils::Smash
