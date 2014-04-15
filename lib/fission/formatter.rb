module Fission
  class Formatter

    autoload :Github, 'fission/formatter/github'

    class << self

      def format(key, source, payload)
        klass = source.to_s.split('_').map(&:capitalize).join.to_sym
        self.const_get(klass).new(payload).data_for(key)
      end

    end

    attr_reader :data, :type

    def initialize(payload, type=nil)
      @data = payload
      @type = (type || 'default').to_sym
    end

    def data_for(key)
      raise NotImplemented.new("No formatter defined for #{key} within #{self.class.name} formatter")
    end

  end
end
