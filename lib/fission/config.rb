require 'mixlib/config'

module Fission
  class Config
    extend Mixlib::Config

    logo true

    log_location STDERR
    log_level :debug

    apis %w[github]

    internal_endpoint ['127.0.0.1', 80]
    
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
        ]
      },
      data_storage: {
        actor_name: 'data_storage',
        enabled: false,
        arguments: [
          adapter: {
            :File => {
              dir: "/srv/fission/data_storage/"
            }
          },
          use: {
            :Lock => {},
            :Logger => {},
            :Expires => {}
          }
        ]
      },
      account_storage: {
        actor_name: 'account_storage',
        enabled: true,
        arguments: [
          adapter: {
            :File => {
              dir: "/srv/fission/account_storage/"
            }
          },
          use: {
            :Lock => {},
            :Logger => {},
            :Expires => {}
          }
        ]
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
        enabled: true,
        arguments: [
          :working_dir: "/srv/fission/container_router",
          :dna_dir: "/srv/fission/container_router_dna"
        ]
      }
    )
  end
end
