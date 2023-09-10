module Signal
  class Attribute
    class Boolean < Attribute
      def set(new_value)
        new_value = !FALSEY.include?(new_value) unless new_value.nil?
        super new_value
      end

      FALSEY = [false, 0, "0", :"0", "f", :f, "F", :F, "false", :false, "FALSE", :FALSE, "off", :off, "OFF", :OFF].freeze # standard:disable Lint/BooleanSymbol
    end
  end
end
