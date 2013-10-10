require 'carnivore/utils'

module Fission
  module Utils
    module MessageUnpack

      class << self
        def included(klass)
          klass.send(:include, Carnivore::Utils::Params)
        end
      end

      def unpack(message)
        if(message[:message] && message[:message][:request])
          begin
            symbolize_hash(MultiJson.load(message[:message][:request].body))
          rescue MultiJson::DecodeError
            message[:message][:request].body
          end
        else
          message
        end
      end

    end
  end
end
