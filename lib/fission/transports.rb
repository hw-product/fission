require 'carnivore'
require 'fission'

=begin
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
