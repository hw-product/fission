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
  s.add_dependency 'jackal'
  s.add_dependency 'celluloid', '~> 0.16.0'
  s.add_dependency 'bogo-cli'
  s.add_dependency 'childprocess'
  s.executables << 'fission'
  s.executables << 'fission-test'
  s.files = Dir['{lib,bin}/**/**/*'] + %w(fission.gemspec README.md CHANGELOG.md)
end
