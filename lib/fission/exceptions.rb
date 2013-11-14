module Fission
  class Error < StandardError

    class ThresholdExceeded < Error; end
    class Locked < Error; end

  end
end
