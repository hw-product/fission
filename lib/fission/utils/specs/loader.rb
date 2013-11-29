require 'carnivore/config'

ENV['FISSION_TESTING_MODE'] = 'true'

path = File.join(Dir.pwd, 'test')

if(File.directory?(path))
  if(File.exists?(spec_file = File.join(path, 'spec.rb')))
    require spec_file
  end
  require 'fission/utils/specs/runner'
else
  raise "No test directory found: #{path}"
end
