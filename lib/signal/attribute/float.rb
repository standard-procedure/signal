module Signal
  class Attribute
    class Float < Attribute
      def set(new_value)
        super new_value&.to_f
      end
    end
  end
end
