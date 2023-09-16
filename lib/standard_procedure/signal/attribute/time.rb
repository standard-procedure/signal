require "date"
require "time"
module StandardProcedure
  module Signal
    class Attribute
      class Time < Attribute
        def set(new_value)
          new_value = case new_value
          when nil then nil
          when ::Time then new_value
          when ::Date then new_value.to_time
          else ::Time.new(new_value)
          end
          super new_value
        rescue => e
          raise FormatError, "Cannot convert #{new_value} into a time: #{e.message}"
        end
      end
    end
  end
end
