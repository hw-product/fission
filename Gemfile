source 'https://rubygems.org'

gem 'carnivore-http'
gem 'carnivore-actor'
gem 'carnivore-rabbitmq'


gem 'octokit'
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


fission = <<-EOF
fission-assets
fission-data
fission-eventer
fission-mail
fission-nellie
fission-package-builder
fission-repository-generator
fission-repository-publisher
fission-rest-api
fission-router
fission-validator
fission-woodchuck
fission-woodchuck-filter
fission-stacks
EOF

fission = fission.split("\n")

if(ENV['FISSION_LOCALS'] == 'true')
  fission.each do |lib|
    gem lib, :path => "../#{lib}"
  end
else
  fission.each do |lib|
    gem lib, :git => "git@github.com:hw-product/#{lib}.git", :branch => 'develop'
  end
end

gemspec
