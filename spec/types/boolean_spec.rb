RSpec.describe Attribute::Boolean do
  it "accepts truthy values as true" do
    ["String", 123, 45.6, Date.today, Time.now, true].each do |value|
      attribute = Attribute.boolean value
      expect(attribute.get).to eq true
    end
  end

  it "accepts falsey values as false" do
    [false, 0, "0", :"0", "f", :f, "F", :F, "false", :false, "FALSE", :FALSE, "off", :off, "OFF", :OFF].each do |value| # rubocop:disable: Line/BooleanSymbol
      attribute = Attribute.boolean value
      expect(attribute.get).to eq false
    end
  end

  it "preserves nils" do
    attribute = Attribute.boolean nil
    expect(attribute.get).to be_nil
  end
end
