require 'mixlib/config'

module Fission
  class Config
    extend Mixlib::Config

    logo true

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
      github: {
        enabled: false
      },
      builder: {
        enabled: false
      },
      collector: {
        enabled: false
      },
      reporter: {
        enabled: false
      }
    )
  end
end
