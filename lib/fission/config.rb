require 'mixlib/config'

module Fission
  class Config
    extend Mixlib::Config

    workers(
      Github: 0,
      Builder: 0,
      Collector: 0,
      Reporter: 0
    )
  end
end
