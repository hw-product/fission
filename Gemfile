source 'https://rubygems.org'

gem 'carnivore-http'
gem 'carnivore-actor'

gem 'octokit'
gem 'elecksee', :path => '/home/spox/Projects/chrisroberts/elecksee'
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
EOF

fission = fission.split("\n")

if(ENV['FISSION_LOCALS'] == 'true')
  fission.each do |lib|
    gem lib, :path => "../#{lib}"
  end
else
  source 'https://fission:8sYl7Bo0ql2OA9OPThUngg@gems.pkgd.io' do
    fission.each do |lib|
      gem lib
    end
  end
end

gemspec
