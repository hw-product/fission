module Fission
  class Error < StandardError

    class ThresholdExceeded < Error; end

  end
end
