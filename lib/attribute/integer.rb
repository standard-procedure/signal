class Attribute
  class Integer < Attribute
    def set new_value
      super new_value&.to_i
    rescue => ex
      raise FormatError.new "Cannot convert #{new_value} to integer"
    end
  end
end
