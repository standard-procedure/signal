module StandardProcedure
  module Signal
    class Attribute
      class Text < Attribute
        def set(new_value)
          super new_value&.to_s
        end
      end
    end
  end
end
