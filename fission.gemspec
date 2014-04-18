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
  s.add_dependency 'celluloid', '0.16.0-pre'
  s.add_dependency 'mixlib-cli'
  s.add_dependency 'childprocess'
  s.add_dependency 'hashie'
  s.executables << 'fission'
  s.executables << 'fission-test'
  s.files = Dir['**/*']
end
