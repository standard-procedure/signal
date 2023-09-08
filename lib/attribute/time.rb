require "date"
require "time"
class Attribute
  class Time < Attribute
    def set new_value
      new_value = case new_value
      when nil then nil
      when ::Time then new_value
      when ::Date then new_value.to_time
      when String then ::Time.new(new_value)
      else raise "#{new_value} not recognised"
      end
      super new_value
    rescue => ex
      raise FormatError.new("Cannot convert #{new_value} into a time: #{ex.message}")
    end
  end
end