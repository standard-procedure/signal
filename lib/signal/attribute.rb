# frozen_string_literal: true

require_relative "observable"

module Signal
  class Attribute
    include Observable
    Dir["#{__dir__}/attribute/*.rb"].sort.each { |file| require file }

    # Create a new, untyped, Attribute, with the given value
    # Alternatively, you can use the class factory methods to build an attribute that automatically performs type conversions.
    # These are Attribute.text, integer, float, boolean, date, time, array, hash
    def initialize(value)
      set value
    end

    class << self
      %i[text integer float date time boolean array hash].each do |type|
        class_name = "Signal::Attribute::#{type.to_s.capitalize}"
        define_method type do |value|
          const_get(class_name).new value
        end
      end

      def for item
        item.is_a?(Signal::Observable) ? item : Attribute.new(item)
      end
    end
  end
end
