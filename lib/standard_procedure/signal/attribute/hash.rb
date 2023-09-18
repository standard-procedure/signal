module StandardProcedure
  module Signal
    class Attribute
      class Hash < Attribute
        include Enumerable

        def set new_value
          new_value = if new_value.nil?
            nil
          elsif new_value.respond_to? :to_hash
            new_value.to_hash.dup
          else
            raise ArgumentError.new "#{new_value.inspect} is not recognised as a Hash"
          end
          super new_value
        end

        def each &block
          get.each(&block)
        end

        def keys
          get.keys
        end

        def include? key
          get.include? key
        end

        def has_key? key
          get.has_key? key
        end

        def has_value? value
          get.has_value? value
        end

        def values
          get.values
        end

        def size
          get.size
        end
        alias_method :length, :size

        def any?
          get.any?
        end

        def empty?
          get.empty?
        end

        def [] key
          get[key]
        end

        def fetch key
          get.fetch key
        end

        def []= key, value
          get[key] = value
          update_observers
        end

        def store key, value
          get.store key, value
          update_observers
        end

        def delete key
          get.delete key
          update_observers
        end

        def clear
          get.clear
          update_observers
        end

        def to_hash
          get
        end
      end
    end
  end
end
