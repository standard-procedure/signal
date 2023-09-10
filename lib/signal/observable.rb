module Signal
  module Observable
    # Get this value converted to a string
    # @return [String]
    def to_s
      @value.to_s
    end

    # Get the value of this signal
    #
    # This method is aliased as `get` and `read` so it can be accessed in whichever way makes most sense to you
    # The following are all equivalent:
    #     @signal.call
    #     @signal.get
    #     @signal.read
    #     @signal.()
    #
    # @return [Object]
    def call
      if (current = call_stack.last)
        observers << current
        current.add observers
      end
      @value
    end
    alias get call
    alias read call

    # Set the value of this signal and notify any observers
    #
    # This method is aliased as `write` it can be used in whichever way makes most sense to you
    # The following are all equivalent:
    #     @signal.set @new_value
    #     @signal.write @new_value
    #
    # @param new_value [Object]
    # @return [Object]
    def set(new_value)
      if new_value != @value
        @value = new_value
        _update_observers
      end
      @value
    end
    alias write set

    # Observe this signal
    #
    # The block will be called whenever this signal or its dependents is updated.
    # The block handler does not require any parameters, simply access the signal, or any other signals and act accordingly.  If you access any dependents outside of this signal, they will be tracked and you will be notified again when they update.
    def observe(&block)
      Signal::Manager.observe(&block)
    end

    def _update_observers
      if update_in_progress?
        updated_observables.add self
      else
        observers.each do |observer|
          observer.call
        end
      end
    end

    private

    def observers
      @observers ||= [] # contains observers
    end

    def call_stack
      Signal::Manager.call_stack
    end

    def update_in_progress?
      Signal::Manager.update_in_progress?
    end

    def updated_observables
      Signal::Manager.updated_observables
    end
  end
end