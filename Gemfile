require File.expand_path('fission_dependencies', File.dirname(__FILE__))
source 'https://rubygems.org'

gem 'carnivore-http'
gem 'carnivore-actor'

gem 'octokit'
gem 'elecksee'
gem 'pg'
gem 'pry'

gem 'minitest'

if(RUBY_PLATFORM == 'java')
  gem 'jruby_sandbox'
end

gem 'jackal-code-fetcher'
gem 'jackal-github'
gem 'jackal-github-kit'
gem 'jackal-slack'
gem 'jackal-stacks'

FissionDependencies::GEMS.each do |lib|
  local  = { path: "../#{lib}" }
  remote = { git: "git@github.com:hw-product/#{lib}.git", branch: 'develop' }
  opts   = ENV['FISSION_LOCALS'] == 'true' ? local : remote

  gem lib, opts
end

gemspec
