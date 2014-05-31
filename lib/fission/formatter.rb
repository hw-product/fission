module Fission
  # Format payload data to common structure
  class Formatter

    autoload :Github, 'fission/formatter/github'

    include Carnivore::Utils::Logging

    class << self

      # Format payload from given source
      #
      # @param key [String, Symbol] what to translate
      # @param source [String, Symbol] source of data (:github)
      # @param payload [Hash]
      def format(key, source, payload)
        klass = source.to_s.split('_').map(&:capitalize).join.to_sym
        self.const_get(klass).new(payload).data_for(key)
      end

    end

    # @return [Hash] payload data
    attr_reader :data
    # @return [Symbol] type of data (when source may provide different formats)
    attr_reader :type

    # Create new instance
    #
    # @param payload [Hash]
    # @param type [String, Symbol] type of data format
    def initialize(payload, type=nil)
      @data = payload
      @type = (type || 'default').to_sym
    end

    # Generate new data structure
    #
    # @param key [String, Symbol] what to translate
    # @return [Hash]
    def data_for(key)
      raise NotImplementedError.new("No formatter defined for #{key} within #{self.class.name} formatter")
    end

  end
end
