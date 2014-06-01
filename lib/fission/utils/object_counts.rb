module Fission
  module Utils
    # Helper for base type count diffing
    module ObjectCounts

      # Count object diffing around given block
      #
      # @param name [String] action identifier
      # @yield block to execute
      # @note requires FISSION_DEBUG_COUNTS env var to be set
      def object_counter(name)
        if(ENV['FISSION_DEBUG_COUNTS'])
          ObjectSpace.garbage_collect
          initial_count = ObjectSpace.count_objects
          result = yield
          ObjectSpace.garbage_collect
          final_count = ObjectSpace.count_objects
          diff = Hash[final_count.map{ |k,v| [k, v - initial_count[k]] }.sort_by(&:first)]
          warn "*********** STAT MARKER [#{name}] ************"
          warn "[#{name}] Object stats: #{diff.inspect}"
          diff.each do |k,v|
            warn "[#{name}] #{k}: #{'+' if v > 0}#{v}"
          end
          warn "[#{name}] Actor count: #{Celluloid::Actor.all.size}"
          result
        else
          yield
        end
      end

    end

  end
end
