# frozen_string_literal: true

module StandardProcedure
  module Signal
    class Observer
      def initialize &block
        @block = block
        @observers = Set.new # contains Sets of Observers
      end

      def add set_of_observers
        @observers.add set_of_observers
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
        @observers.each do |observer|
          observer.delete self
        end
        @observers.clear
        call_stack.push self
      end

      def finish
        call_stack.pop
      end

      def call_stack
        Signal::Manager.call_stack
      end
    end
  end
end
