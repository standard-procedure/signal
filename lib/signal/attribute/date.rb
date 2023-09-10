require 'date'
require 'time'
module Signal
  class Attribute
    class Date < Attribute
      def set(new_value)
        new_value = case new_value
                    when nil then nil
                    when ::Date then new_value
                    when ::Time then ::Date.new(new_value.year, new_value.month, new_value.day)
                    when String then ::Date.parse(new_value)
                    else raise "#{new_value} not recognised"
                    end
        super new_value
      rescue StandardError => e
        raise FormatError, "Cannot convert #{new_value} into a date: #{e.message}"
      end
    end
  end
end
