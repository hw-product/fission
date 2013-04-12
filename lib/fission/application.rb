module Fission
  class Application
    class << self

      def apply_config(config_file_path)
        Fission::Config.from_file(config_file_path)
        Fission::Config.merge!(config)
      end

      def boot
        Fission::Logger.override_celluloid_logger
        
        if Fission::Config[:logo]
          puts Fission.logo
        end

        Fission::Supervisor.run!
      end

      def shutdown
        Celluloid.shutdown
      end
    end
  end
end
