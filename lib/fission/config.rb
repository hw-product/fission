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
            :Expires => {},
            :Transformer => {
              value: [
                :marshal,
                :zlib
              ]
            }
          }
        ],
      },
      package_builder: {
        actor_name: 'package_bulider',
        enabled: true
      },
      repository_fetcher: {
        actor_name: 'repository_fetcher',
        enabled: true,
        arguments: [
          working_dir: "/srv/fission/repositories/"
        ]
      },
      container_router: {
        actor_name: 'container_router',
        enabled: true
      },
    )
  end
end
