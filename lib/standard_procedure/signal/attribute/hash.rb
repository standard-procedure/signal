module StandardProcedure
  module Signal
    class Attribute
      class Hash < Attribute
        include Enumerable

        def set(new_value)
          new_value = if new_value.nil?
            nil
          elsif new_value.respond_to? :transform_values
            new_value.transform_values { |value| Attribute.for value }
          else
            raise ArgumentError.new "#{new_value.inspect} is not recognised as a Hash"
          end
          super new_value
        end

        def each &block
          @value.each(&block)
        end

        def keys
          @value.keys
        end

        def include? key
          @value.include? key
        end

        def has_key? key
          @value.has_key? key
        end

        def has_value? value, attribute: false
          if attribute
            @value.has_value? value
          else
            @value.values.map(&:get).include? value
          end
        end

        def values
          @value.values
        end

        def size
          @value.size
        end
        alias_method :length, :size

        def any?
          @value.any?
        end

        def empty?
          @value.empty?
        end

        def [] key
          @value[key]
        end

        def fetch key
          @value.fetch key
        end

        def []= key, value
          @value[key] = value
          update_observers
        end

        def store key, value
          @value.store key, value
          update_observers
        end

        def delete key
          @value.delete key
          update_observers
        end

        def clear
          @value.clear
          update_observers
        end
      end
    end
  end
end
