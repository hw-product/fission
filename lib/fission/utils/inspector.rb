module Fission
  module Utils
    # State inpsection of running fission
    module Inspector

      # Check if feature is enabled
      #
      # @param thing [String, Symbol] name of feature
      # @return [TrueClass, FalseClass]
      def enabled?(thing)
        !config_disabled(thing) && (config_enabled(thing) || constant_enabled(thing))
      end

      # Check if feature is disabled
      #
      # @param thing [String, Symbol] name of feature
      # @return [TrueClass, FalseClass]
      def disabled?(thing)
        !enabled?(thing)
      end

      # Check if feature is enabled in configuration
      #
      # @param thing [String, Symbol] name of feature
      # @return [TrueClass, FalseClass]
      def config_enabled(thing)
        check = thing.to_s
        to_check = [Carnivore::Config.get(:fission, :core, :enable)].flatten.compact
        to_check.include?(check)
      end

      # Check if feature is disabled in configuration
      #
      # @param thing [String, Symbol] name of feature
      # @return [TrueClass, FalseClass]
      def config_disabled(thing)
        check = thing.to_s
        to_check = [Carnivore::Config.get(:fission, :core, :disable)].flatten.compact
        to_check.include?(check)
      end

      # Check if feature is defined constant at top level or within [Fission]
      #
      # @param thing [String, Symbol] name of feature
      # @return [TrueClass, FalseClass]
      # @todo add support for namespace walking. pretty sure i can
      # grab from existing utility within mod_spox code
      def constant_enabled(thing)
        Fission.constants.map do |const|
          const.to_s.downcase.to_sym
        end.include?(thing.to_s.downcase.to_sym)
      end

    end

    extend Inspector
  end
end
