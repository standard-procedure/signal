RSpec.describe StandardProcedure::Signal::Attribute::Integer do
  it "converts values to integers" do
    ["String", 123, 45.6, Time.now].each do |value|
      attribute = StandardProcedure::Signal::Attribute.integer value
      expect(attribute.get).to eq value.to_i
      expect(attribute.to_s).to eq value.to_i.to_s
    end
  end

  it "raises a FormatError if it cannot perform the conversion" do
    [Date.today, false].each do |value|
      expect { StandardProcedure::Signal::Attribute.integer(value) }.to raise_exception(StandardProcedure::Signal::Attribute::FormatError)
    end
  end

  it "preserves nils" do
    attribute = StandardProcedure::Signal::Attribute.integer nil
    expect(attribute.get).to be_nil
  end
end
