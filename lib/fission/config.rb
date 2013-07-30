require 'mixlib/config'

module Fission
  class Config
    extend Mixlib::Config

    logo true

    log_location STDERR
    log_level :debug

    apis %w[github]

    workers(
      webhook: {
        actor_name: 'webhook',
        enabled: true,
        arguments: %w[0.0.0.0 8000]
      },
      object_storage: {
        actor_name: 'object_storage',
        enabled: true,
        arguments: [
          adapter: {
            :File => {
              dir: "/srv/fission/object_storage/"
            }
          },
          use: {
            :Lock => {},
            :Logger => {},
            :Expires => {}
          }
        ],
      },
      test_runner: {
        actor_name: 'test_runner',
        enabled: true
      },
      repository_fetcher: {
        actor_name: 'repository_fetcher',
        enabled: true,
        arguments: [
          working_dir: "/srv/fission/repositories/"
        ]
      },
      test_kitchen: {
        actor_name: 'test_kitchen',
        enabled: true
      },
    )
  end
end
