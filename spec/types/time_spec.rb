RSpec.describe StandardProcedure::Signal::Attribute::Time do
  it "keeps exact time values" do
    t = Time.now
    attribute = StandardProcedure::Signal::Attribute.time t
    expect(attribute.get).to eq t
  end

  it "converts dates into times" do
    attribute = StandardProcedure::Signal::Attribute.time Date.today
    expect(attribute.get).to eq Date.today.to_time
  end

  it "parses strings to dates" do
    ["2023-01-01T15:24:22", "2000-12-31 23:59:59.5 +0900"].each do |value|
      attribute = StandardProcedure::Signal::Attribute.time value
      expect(attribute.get).to eq Time.new(value)
      expect(attribute.to_s).to eq Time.new(value).to_s
    end
  end

  # Javascript returns a time object containing NaN when using the Time conversion routine in Opal
  # So this spec never works - it does work in other ruby environments though
  if RUBY_ENGINE != "opal"
    it "raises a FormatError if it cannot perform the conversion" do
      ["Some stuff", false].each do |value|
        expect { StandardProcedure::Signal::Attribute.time(value) }.to raise_exception(StandardProcedure::Signal::Attribute::FormatError)
      end
    end
  end

  it "preserves nils" do
    attribute = StandardProcedure::Signal::Attribute.time nil
    expect(attribute.get).to be_nil
  end
end
