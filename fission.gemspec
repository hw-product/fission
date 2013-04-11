# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'fission/version'

Gem::Specification.new do |gem|
  gem.name        = 'fission'
  gem.version     = Fission::VERSION
  gem.platform    = Gem::Platform::RUBY
  gem.summary     = 'Multi-platform package build and publishing system'
  gem.description = 'Fission enables people to build omnibus-style isolated packages for deployment on multiple operating systems, triggered via Github webhook'
  gem.licenses    = ['APLv2']

  gem.authors     = ['Heavy Water Operations, LLC (OR)']
  gem.email       = ['support@hw-ops.com']
  gem.homepage    = 'https://github.com/heavywater/fission'

  gem.required_ruby_version     = '>= 1.9.2'
  gem.required_rubygems_version = '>= 1.3.6'

  gem.files        = Dir['README.md', 'lib/**/*', 'spec/support/**/*']
  gem.require_path = 'lib'

  gem.add_runtime_dependency 'mixlib-config'
  gem.add_runtime_dependency 'logger'
  gem.add_runtime_dependency 'celluloid', '>= 0.13.0'
  gem.add_runtime_dependency 'celluloid-io', '>= 0.13.1'
  gem.add_runtime_dependency 'reel', '>= 0.3.0'
  gem.add_runtime_dependency 'octarine', '>= 0.0.3'
  gem.add_runtime_dependency 'rack', '>= 1.5.2'
  gem.add_runtime_dependency 'multi_json'
  gem.add_runtime_dependency 'blockenspiel'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'benchmark_suite'
  gem.add_development_dependency 'coveralls'
end
