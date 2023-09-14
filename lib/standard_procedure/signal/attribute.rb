# frozen_string_literal: true

require_relative "observable"
module StandardProcedure
  module Signal
    class Attribute
      include Observable
      require_relative "attribute/format_error"
      require_relative "attribute/array"
      require_relative "attribute/boolean"
      require_relative "attribute/date"
      require_relative "attribute/float"
      require_relative "attribute/hash"
      require_relative "attribute/integer"
      require_relative "attribute/text"
      require_relative "attribute/time"

      # Create a new, untyped, Attribute, with the given value
      # Alternatively, you can use the class factory methods to build an attribute that automatically performs type conversions.
      # These are Attribute.text, integer, float, boolean, date, time, array, hash
      def initialize(value)
        set value
      end

      TYPES = %i[text integer float date time boolean array hash].freeze
      class << self
        TYPES.each do |type|
          class_name = "StandardProcedure::Signal::Attribute::#{type.to_s.capitalize}"
          define_method type do |value|
            const_get(class_name).new value
          end
        end

        def for item
          item.is_a?(StandardProcedure::Signal::Observable) ? item : Attribute.new(item)
        end
      end
    end
  end
end
