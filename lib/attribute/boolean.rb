class Attribute
  class Boolean < Attribute
    def set new_value
      new_value = FALSEY.include?(new_value) ? false : true unless new_value.nil?
      super new_value
    end

    FALSEY = [false, 0, "0", :"0", "f", :f, "F", :F, "false", :false, "FALSE", :FALSE, "off", :off, "OFF", :OFF].freeze # rubocop:disable: Line/BooleanSymbol
  end
end
