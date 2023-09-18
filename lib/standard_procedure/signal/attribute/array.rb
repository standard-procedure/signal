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
          get.push item
          update_observers
          self
        end
        alias_method :<<, :push

        def pop
          item = get.pop
          update_observers
          item
        end

        def shift
          item = get.shift
          update_observers
          item
        end

        def unshift item
          get.unshift item
          update_observers
          self
        end

        def last
          get.last
        end

        def each &block
          get.each(&block)
        end
      end
    end
  end
end
