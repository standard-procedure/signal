class Attribute
  class Listener
    def initialize &block
      @block = block
      @listeners = Set.new # contains Sets of Listeners
    end

    def add set_of_listeners
      @listeners.add set_of_listeners
    end

    def call
      start
      begin
        @block.call
      ensure
        finish
      end
    end

    def start
      @listeners.each do |listener|
        listener.delete self
      end
      @listeners.clear
      call_stack.push self
    end

    def finish
      call_stack.pop
    end

    def call_stack
      Attribute._call_stack
    end
  end
end
