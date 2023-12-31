RSpec.describe StandardProcedure::Signal::Attribute::Date do
  it "keeps exact date values" do
    attribute = StandardProcedure::Signal::Attribute.date Date.today
    expect(attribute.get).to eq Date.today
  end

  it "converts times into dates" do
    attribute = StandardProcedure::Signal::Attribute.date Time.now
    expect(attribute.get).to eq Date.today
  end

  it "parses strings to dates" do
    ["2023-01-01", "12th January 1977"].each do |value|
      attribute = StandardProcedure::Signal::Attribute.date value
      expect(attribute.get).to eq Date.parse(value)
      expect(attribute.to_s).to eq Date.parse(value).to_s
    end
  end

  it "raises a FormatError if it cannot perform the conversion" do
    ["Some stuff", 123, false].each do |value|
      expect { StandardProcedure::Signal::Attribute.date(value) }.to raise_exception(StandardProcedure::Signal::Attribute::FormatError)
    end
  end

  it "preserves nils" do
    attribute = StandardProcedure::Signal::Attribute.date nil
    expect(attribute.get).to be_nil
  end
end
