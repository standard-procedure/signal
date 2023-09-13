module StandardProcedure
  module Signal
    class Attribute
      class Integer < Attribute
        def set(new_value)
          super new_value&.to_i
        rescue
          raise FormatError, "Cannot convert #{new_value} to integer"
        end
      end
    end
  end
end
