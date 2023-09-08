RSpec.describe Attribute::Text do
  it "converts the value to a string" do
    ["String", 123, 45.6, Date.today, Time.now, false].each do |value|
      attribute = Attribute.text value
      expect(attribute.get).to eq value.to_s
      expect(attribute.to_s).to eq value.to_s
    end
  end

  it "preserves nils" do
    attribute = Attribute.text nil
    expect(attribute.get).to be_nil
  end
end
