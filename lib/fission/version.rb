module Fission
  class Version < Gem::Version
  end

  VERSION = Version.new('0.0.1')
  def self.version; VERSION; end
end
