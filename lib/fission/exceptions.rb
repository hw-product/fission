module Fission
  class Error < StandardError

    class ThresholdExceeded < Error; end
    class Locked < Error; end
    class NotImplemented < Error; end

  end
end
