require 'attribute_struct'

class Packomatic < AttributeStruct
  class << self
    def describe
      self.new do
        yield
      end
    end

    def base
      self.new do
        target.package 'deb'
        target.arch 'x86_64'
        dependencies.build []
        dependencies.runtime []
        dependencies.package {}
        build.commands.before do
          dependencies []
          build []
        end
        build.commands.after do
          dependencies []
          build []
        end
        build.commands.build []
        callbacks do
        end
      end
    end
  end
end
