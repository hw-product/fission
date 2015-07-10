require 'fission'

module Fission
  module Utils
    # Helpers for spec testings
    module Specs
      autoload :CallbackLocal, 'fission/utils/specs/callback_local'
      autoload :Generator,     'fission/utils/specs/generator'
    end
  end
end
