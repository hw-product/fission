require 'mixlib/config'

module Fission
  class Config
    extend Mixlib::Config

    logo true

    log_location STDERR
    log_level :info
    
    apis %w[github]
    workers(
      webhook: {
        actor_name: 'webhook',
        enabled: true,
        arguments: %w[0.0.0.0 8000]
      },
      transport: {
        actor_name: 'transport',
        enabled: true
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
            :Logger => {
              logger: Celluloid.logger
            },
            :Expires => {},
            :Transformer => {
              value: :zlib
            }
          }
        ],
      },
      package_builder: {
        actor_name: 'package_bulider',
        enabled: false
      }
    )
  end
end
