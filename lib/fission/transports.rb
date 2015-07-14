require 'carnivore'
require 'fission'

=begin
Example structure of sources:

{
  :fission => {
    :sources => {
      :package_builder => {
        :type => 'sqs',
        :args => {
        }
      }
    }
  }
}
=end

module Fission
  # Fission style setup of Carnivore sources
  class Transports
    class << self

      # Build all registered Carnivore::Source transports
      def build!
        Array(Carnivore::Config.get(:fission, :loaders, :sources)).flatten.compact.each do |lib|
          require lib
        end
        sources = Carnivore::Config.get(:fission, :sources)
        if(sources)
          Carnivore.configure do
            sources.each do |name, opts|
              unless name.is_a? String && opts.is_a? Hash
                raise TypeError.new "Expected a source build to have a name and hash. " <<
                  "name: #{name.inspect}, opts: #{opts.inspect}"
              end
              Carnivore::Source.build(
                :type => opts[:type].to_sym,
                :args => opts.fetch(:args, {}).merge(:name => name.to_sym)
              )
            end
          end
        else
          raise ArgumentError.new('Failed to retrieve source information from configuration')
        end
      end

    end
  end
end
