module Fission
  class Logger
    LEVELS = {
      debug: ::Logger::DEBUG,
      info: ::Logger::INFO,
      warn: ::Logger::WARN,
      error: ::Logger::ERROR,
      fatal: ::Logger::FATAL
    }.freeze

    LEVEL_NAMES = LEVELS.invert.freeze
    
    def self.override_celluloid_logger
      log_location = Fission::Config[:log_location]
      log_level = Fission::Config[:log_level]

      logger = ::Logger.new(log_location)
      logger.level = LEVELS[log_level]
      
      Celluloid.logger = logger
    end

  end
end
