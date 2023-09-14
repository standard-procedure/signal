if RUBY_ENGINE == "opal"
  class Signal
    extend StandardProcedure::Signal
  end
else
  module Signal
    extend StandardProcedure::Signal
  end
end
