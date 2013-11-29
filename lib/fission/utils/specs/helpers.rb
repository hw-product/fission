require 'multi_json'
require 'carnivore/spec_helper'

def payload_for(style, args={})
  dir = File.join(File.dirname(__FILE__), '../../../../examples/payloads')
  path = File.join(dir, "#{style}.json")
  if(File.exists?(path))
    if(args[:raw])
      MultiJson.load(File.read(path))
    else
      if(args[:nest])
        Fission::Utils.new_payload(:test, args[:nest] => MultiJson.load(File.read(path)))
      else
        Fission::Utils.new_payload(:test, File.read(path))
      end
    end
  else
    raise "Requested payload path for test does not exist: #{File.expand_path(path)}"
  end
end
