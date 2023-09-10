RSpec.describe Signal::Attribute::Time do
  it "keeps exact time values" do
    t = Time.now
    attribute = Signal::Attribute.time t
    expect(attribute.get).to eq t
  end

  it "converts dates into times" do
    attribute = Signal::Attribute.time Date.today
    expect(attribute.get).to eq Date.today.to_time
  end

  it "parses strings to dates" do
    ["2023-01-01T15:24:22", "2000-12-31 23:59:59.5 +0900"].each do |value|
      attribute = Signal::Attribute.time value
      expect(attribute.get).to eq Time.new(value)
      expect(attribute.to_s).to eq Time.new(value).to_s
    end
  end

  it "raises a FormatError if it cannot perform the conversion" do
    ["Some stuff", 123, false].each do |value|
      expect { Signal::Attribute.time(value) }.to raise_exception(Signal::Attribute::FormatError)
    end
  end

  it "preserves nils" do
    attribute = Signal::Attribute.time nil
    expect(attribute.get).to be_nil
  end
end
