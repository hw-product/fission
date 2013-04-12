source "https://rubygems.org"

group :integration do
  gem 'berkshelf'
  gem 'test-kitchen', github: 'opscode/test-kitchen', branch: '1.0'
  gem 'kitchen-lxc', github: 'portertech/kitchen-lxc'
  gem 'rb-inotify', '~> 0.9' if RUBY_PLATFORM =~ /linux/
end

gem 'celluloid', github: 'celluloid/celluloid', branch: 'master'
gem 'celluloid-io', github: 'celluloid/celluloid-io', branch: 'master'
gem 'reel', github: 'celluloid/reel', branch: 'master'

gemspec
