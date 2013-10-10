$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'fission/version'
Gem::Specification.new do |s|
  s.name = 'fission'
  s.version = Fission::VERSION.version
  s.summary = 'Fission Core'
  s.author = 'Heavywater'
  s.email = 'fission@hw-ops.com'
  s.homepage = 'http://github.com/heavywater/fission'
  s.description = 'Fission Core'
  s.require_path = 'lib'
  s.add_dependency 'carnivore'
#  s.add_dependency 'carnivore-sqs'
  s.add_dependency 'celluloid'
  s.files = Dir['**/*']
end
