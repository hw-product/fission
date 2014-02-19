module Fission
  module Utils
    module Inspector

      # thing:: String or symbol of feature
      # Returns true if `thing` is enabled
      def enabled?(thing)
        !config_disabled(thing) && (config_enabled(thing) || constant_enabled(thing))
      end

      # thing:: String or symbol of feature
      # Returns true if `thing` is disabled
      def disabled?(thing)
        !enabled?(thing)
      end

      # thing:: String or symbol of feature
      # Returns true if `thing` is enabled in configuration
      def config_enabled(thing)
        check = thing.to_s
        to_check = [Carnivore::Config.get(:fission, :core, :enable)].flatten.compact
        to_check.include?(check)
      end

      # thing:: String or symbol of feature
      # Returns true if `thing` is disabled in configuration
      def config_disabled(thing)
        check = thing.to_s
        to_check = [Carnivore::Config.get(:fission, :core, :disable)].flatten.compact
        to_check.include?(check)
      end

      # thing:: String or symbol to check if constant is defined
      # Returns true if `thing` is a defined constant either at the top
      # level or within `Fission`
      # TODO: I didn't feel like implementing it now, but add support to
      # walk namespaces through constant list (i think i have this in a
      # mod_spox util)
      def constant_enabled(thing)
        Fission.constants.map do |const|
          const.to_s.downcase.to_sym
        end.include?(thing.to_s.downcase.to_sym)
      end

    end

    extend Inspector
  end
end
