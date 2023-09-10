RSpec.describe Signal::Attribute::Float do
  it "converts values to floats" do
    ["String", 123, 45.6, Time.now].each do |value|
      attribute = Signal::Attribute.float value
      expect(attribute.get).to eq value.to_f
      expect(attribute.to_s).to eq value.to_f.to_s
    end
  end

  it "raises a FormatError if it cannot perform the conversion" do
    [Date.today, false].each do |value|
      expect { Signal::Attribute.float(value) }.to raise_exception(StandardError)
    end
  end

  it "preserves nils" do
    attribute = Signal::Attribute.float nil
    expect(attribute.get).to be_nil
  end
end
