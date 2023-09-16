module StandardProcedure
  module Signal
    class Attribute
      class Array < Attribute
        include Enumerable

        def set(new_value)
          new_value = if new_value.nil?
            nil
          elsif new_value.is_a? Enumerable
            new_value.dup
          else
            [new_value]
          end
          super new_value
        end

        def push item
          @value.push item
          update_observers
          self
        end
        alias_method :<<, :push

        def pop
          item = @value.pop
          update_observers
          item
        end

        def shift
          item = @value.shift
          update_observers
          item
        end

        def unshift item
          @value.unshift item
          update_observers
          self
        end

        def last
          @value.last
        end

        def each &block
          @value.each(&block)
        end
      end
    end
  end
end
