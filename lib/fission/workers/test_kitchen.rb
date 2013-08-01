module Fission
  module Kitchen
    class Loader
      def initialize kitchen_root
        @kitchen_file = File.join(
          kitchen_root,
          '.kitchen.yml'
        )

        @fission_file = File.join(
          kitchen_root,
          '.fission.yml'
        )
      end

      def read
        kitchen_config.rmerge(fission_config).rmerge(overrides)
      end

      private

      def loader(file, options={})
        ::Kitchen::Loader::YAML.new(file, options)
      end

      def kitchen_config
        loader(@kitchen_file, process_erb: false).read
      end

      def fission_config
        if File.exists?(@fission_file)
          loader(@fission_file, process_erb: false).read
        else
          {}
        end
      end

      def overrides
        {
          driver_plugin: 'docker',
          irc: {
            uri: 'irc://fission:heavywater@heavywater.irc.grove.io:6697/#HeavyWater',
            nickserv_password: 'boosterjuice8',
            ssl: true
          }
        }
      end

    end
  end

  class Worker::TestKitchen < Worker

    attr_reader :options

    def initialize options={}
      @options = options
      Actor[:transport].register :test_kitchen, current_actor
      info 'Test Kitchen initialized'
    end

    def test_instance instance
      result = {
        name: instance.name,
        log_file: File.join(instance.driver[:kitchen_root], '.kitchen', 'logs', instance.name)
      }
      begin
        instance.test
        result[:passed] = true
      rescue ::Kitchen::InstanceFailure, ::Kitchen::ActionFailed => error
        puts error.message
        puts error.backtrace.join("\n")
        result[:passed] = false
      ensure
        instance.destroy
      end
      result
    end

    def test_from_repository repository_identifier
      kitchen_root = File.join(
        options[:working_dir],
        repository_identifier
      )

      loader = Kitchen::Loader.new(kitchen_root)
      config = loader.read

      kitchen_config = ::Kitchen::Config.new(
        :loader => loader,
        :kitchen_root => kitchen_root,
        :test_base_path => File.join(kitchen_root, 'test/integration'),
        :supervised => false
      )

      results = kitchen_config.instances.map do |instance|
        test_instance instance
      end

      if config[:irc]
        Actor[:transport][:test_notifier].notify_irc_channel(
          config[:irc],
          results
        )
      end

      unless results.all? { |result| result[:passed] }; end

    end

    def terminate
    end

  end
end
