module Fission
  class Worker::TestKitchen < Worker

    attr_reader :options

    def initialize options={}
      @options = options
      Actor[:transport].register :test_kitchen, current_actor
      info 'Test Kitchen initialized'
    end

    def test_from_repository repository_identifier
      kitchen_root = File.join(
        options[:working_dir],
        repository_identifier
      )

      yaml_file = File.join(
        kitchen_root,
        '.kitchen.yml'
      )

      loader = Kitchen::Loader::YAML.new(yaml_file)

      config = Kitchen::Config.new(
        :loader => loader,
        :kitchen_root => kitchen_root,
        :test_base_path => File.join(kitchen_root, 'test/integration'),
        :supervised => false
      )

      config.instances.map { |i| i.test }
    end

    def terminate
    end

  end
end
