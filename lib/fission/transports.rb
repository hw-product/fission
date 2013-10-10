require 'carnivore'
require 'carnivore-sqs'

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
      def build!
        sources = Carnivore::Config.get(:fission, :sources)
        if(sources)
          Carnivore.configure do
            sources.each do |name, opts|
              require "carnivore-#{opts[:type]}"
              Carnivore::Source.build(
                :type => opts[:type].to_sym,
                :args => opts[:args]
              )
            end
          end
        else
          raise ArgumentError.new('Failed to retreive source information from configuration')
        end
      end
    end
  end
end
