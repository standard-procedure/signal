if defined?(Signal) && Signal.is_a?(Class)
  class Signal
    extend StandardProcedure::Signal
  end
else
  module Signal
    extend StandardProcedure::Signal
  end
end
